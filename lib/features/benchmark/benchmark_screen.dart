// FoodAI end-to-end latency benchmark screen (hidden, build-time gated).
//
// Measures end-to-end latency ON THE HANDSET: from "the request starts" until the JSON
// with the prediction + nutritional data is parsed. Mirrors exactly what
// FoodDetectionsDataSourceImpl.analyzeFoodImage does (same Dio client, same endpoint,
// same fields) EXCEPT it reads pre-captured benchmark images instead of the camera, so
// capture time itself is excluded (the reviewer asked for the network/inference cost,
// not how long the user takes to frame a photo). No compression step: the real app sends
// the camera file as-is (see food_detections_datasource_impl.dart), so this screen does too.
//
// Added for the latency benchmark requested by ICACIT Reviewer 1 (rigor: N>=100 trials,
// device, network, percentiles, CPU/GPU). Full protocol: paper/benchmark_latencia/PROTOCOLO.md.
//
// HOW TO USE
// ----------
// 1. Put 25 test-split images (one per class, distinct classes) in assets/bench/
//    (declared in pubspec.yaml) and list them in `kAssets` below.
// 2. Wire a route to this screen — see lib/config/router/app_router.dart, gated behind
//    `bool.fromEnvironment('BENCH_MODE')` (this app had no --dart-define pattern before).
// 3. Build and install:
//        flutter build apk --release --dart-define=BENCH_MODE=true
//        adb install -r build/app/outputs/flutter-apk/app-release.apk
//    (Use --release, not --debug: debug builds add JIT overhead to the client timing.)
// 4. Log in normally first, with a DEDICATED TEST ACCOUNT (Firebase Auth session must
//    exist — this screen reuses the app's stored token exactly like every other
//    authenticated call).
// 5. Run with Wi-Fi OFF on 4G, then pull the CSV:
//        adb shell run-as com.example.foodai cat files/latency_<label>.csv > run_phone_4g.csv
//    (adjust the applicationId if it differs) or tap "Share CSV" in the screen.
//
// SIDE EFFECTS: every successful call creates a real row in the production Postgres DB
// and a real blob in Azure Blob Storage (same as any normal capture). This screen calls
// DELETE on every created detection after the run (button "Cleanup", not timed) — the
// backend also deletes the blob when a detection is deleted
// (FoodDetectionController.deleteDetection).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/const/environments.dart'; // Environment.apiUrl, same as the app

// ------------------------------------------------------------------ CONFIG ----
const String kPredictPath = '/food-detections/analyze'; // Dio baseUrl already has /api/v1
const String kCategory = 'ALMUERZO'; // FoodCategory enum: DESAYUNO | ALMUERZO | CENA
const int kRounds = 5;
const int kWarmup = 5;
const Duration kPause = Duration(seconds: 1);
const List<String> kAssets = [
  // 25 test-split images, distinct classes. Fill in real filenames from assets/bench/.
  // 'assets/bench/ceviche.jpg',
  // 'assets/bench/lomo_saltado.jpg',
];
// ------------------------------------------------------------------------------

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({super.key});
  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen> {
  final _log = <String>[];
  final _labelCtrl = TextEditingController(text: 'phone_4g');
  bool _running = false;
  File? _csv;
  final _createdIds = <int>[];

  // Server-Timing stage -> CSV column (same schema as paper/benchmark_latencia/client/bench_client.py).
  static const _stageCols = <String, String>{
    'blob': 'srv_blob_ms',
    'ai': 'srv_ai_ms',
    'ai_download': 'ai_download_ms',
    'ai_decode': 'ai_decode_ms',
    'ai_preprocess': 'ai_preprocess_ms',
    'ai_inference': 'ai_inference_ms',
    'ai_total': 'ai_total_ms',
    'db_lookup': 'srv_db_lookup_ms',
    'db_persist': 'srv_db_persist_ms',
    'total': 'srv_total_ms',
  };
  static final _header = [
    'trial', 'round', 'image', 'bytes_sent', 'http_status', 't_client_ms',
    ..._stageCols.values, 'warmup', 'label', 'ts_iso', 'detection_id',
  ].join(',');

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl, // same base URL the app uses (includes /api/v1)
    headers: {'Accept': 'application/json'},
  ));

  Map<String, double> _parseServerTiming(String? h) {
    final out = <String, double>{};
    if (h == null) return out;
    for (final part in h.split(',')) {
      final segs = part.trim().split(';');
      final name = segs.first.trim();
      for (final kv in segs.skip(1)) {
        final p = kv.trim().split('=');
        if (p.length == 2 && p[0] == 'dur') {
          final v = double.tryParse(p[1]);
          if (v != null) out[name] = v;
        }
      }
    }
    return out;
  }

  void _appendLog(String s) => setState(() => _log.insert(0, s));

  Future<String> _authToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Log in first (this screen reuses the app session)');
    final token = await user.getIdToken();
    if (token == null) throw StateError('Could not obtain Firebase ID token');
    return token;
  }

  Future<void> _run() async {
    if (_running) return;
    if (kAssets.isEmpty) {
      _appendLog('kAssets is empty — fill it in with the 25 assets/bench/*.jpg filenames first.');
      return;
    }
    setState(() { _running = true; _log.clear(); _createdIds.clear(); });

    final label = _labelCtrl.text.trim();
    final dir = await getApplicationDocumentsDirectory();
    final csv = File('${dir.path}/latency_$label.csv');
    final sink = csv.openWrite();
    sink.writeln(_header);

    final today = DateTime.now().toIso8601String().split('T').first; // yyyy-MM-dd

    // Pre-load payloads BEFORE timing: asset I/O must not count against t_client_ms.
    // No compression: the production app sends the captured file as-is.
    final payloads = <String, Uint8List>{};
    for (final a in kAssets) {
      payloads[a] = (await rootBundle.load(a)).buffer.asUint8List();
    }

    var trial = 0;
    try {
      for (var round = 1; round <= kRounds; round++) {
        for (final a in kAssets) {
          trial++;
          final bytes = payloads[a]!;
          final name = a.split('/').last;

          final sw = Stopwatch()..start();
          var status = -1;
          var st = <String, double>{};
          int? detectionId;
          try {
            final token = await _authToken();
            final form = FormData.fromMap({
              'image': MultipartFile.fromBytes(bytes, filename: name),
              'category': kCategory,
              'detectionDate': today,
            });
            final resp = await _dio.post<dynamic>(
              kPredictPath,
              data: form,
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'multipart/form-data',
                },
                validateStatus: (_) => true, // read status ourselves, don't throw
              ),
            );
            status = resp.statusCode ?? -1;
            st = _parseServerTiming(resp.headers.value('server-timing'));
            if (status == 201) {
              final body = resp.data is String ? jsonDecode(resp.data as String) : resp.data;
              detectionId = (body as Map<String, dynamic>)['id'] as int?;
              if (detectionId != null) _createdIds.add(detectionId);
            } else {
              _appendLog('trial $trial HTTP $status: ${resp.data}');
            }
          } catch (e) {
            _appendLog('trial $trial error: $e');
          }
          sw.stop();
          final tClient = sw.elapsedMicroseconds / 1000.0;

          String f(String k) => st.containsKey(k) ? st[k]!.toStringAsFixed(2) : '';
          sink.writeln([
            trial, round, name, bytes.length, status, tClient.toStringAsFixed(2),
            ..._stageCols.keys.map(f),
            trial <= kWarmup ? 1 : 0, label,
            DateTime.now().toUtc().toIso8601String(), detectionId ?? '',
          ].join(','));

          _appendLog('[$trial] $name $status client=${tClient.toStringAsFixed(0)} ms '
              'blob=${f('blob')} ai=${f('ai')} inf=${f('ai_inference')} '
              'db_lookup=${f('db_lookup')} db_persist=${f('db_persist')}');
          await Future.delayed(kPause);
        }
      }
    } finally {
      await sink.flush();
      await sink.close();
      setState(() { _running = false; _csv = csv; });
      _appendLog('DONE: $trial trials, ${_createdIds.length} detections created -> ${csv.path}');
    }
  }

  Future<void> _cleanup() async {
    if (_createdIds.isEmpty) { _appendLog('Nothing to clean up.'); return; }
    _appendLog('Cleaning up ${_createdIds.length} test detections...');
    final token = await _authToken();
    var ok = 0;
    for (final id in List<int>.from(_createdIds)) {
      try {
        final resp = await _dio.delete<dynamic>(
          '/food-detections/$id',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (_) => true,
          ),
        );
        if (resp.statusCode == 204 || resp.statusCode == 200) {
          ok++;
          _createdIds.remove(id);
        } else {
          _appendLog('  delete $id: HTTP ${resp.statusCode}');
        }
      } catch (e) {
        _appendLog('  delete $id: error $e');
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
    _appendLog('Cleanup done: $ok deleted.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FoodAI latency benchmark')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(
            controller: _labelCtrl,
            decoration: const InputDecoration(labelText: 'Run label (phone_4g / phone_wifi)'),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ElevatedButton(
              onPressed: _running ? null : _run,
              child: Text(_running ? 'Running…' : 'Run ${kRounds}×${kAssets.length}'),
            ),
            ElevatedButton(
              onPressed: _csv == null
                  ? null
                  : () => Share.shareXFiles([XFile(_csv!.path)], text: 'FoodAI latency CSV'),
              child: const Text('Share CSV'),
            ),
            ElevatedButton(
              onPressed: _createdIds.isEmpty ? null : _cleanup,
              child: Text('Cleanup (${_createdIds.length})'),
            ),
          ]),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (_, i) => Text(_log[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
            ),
          ),
        ]),
      ),
    );
  }
}
