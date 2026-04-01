import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/domain/entities/auth_state.dart';
import 'package:foodai/features/auth/presentation/providers/auth_provider.dart';
import 'package:foodai/features/profile/domain/domain.dart';
import 'package:foodai/features/profile/infrastructure/infrastructure.dart';
import 'package:foodai/shared/infrastructure/services/key_value_service.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  final storageService = ref.read(keyValueStorageServiceProvider);

  return GoalsRepositoryImpl(
    dataSource: GoalsDataSourceImpl(storageService: storageService),
  );
});

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<UserGoals>>((ref) {
      final GoalsRepository goalsRepository = ref.watch(
        goalsRepositoryProvider,
      );

      return GoalsNotifier(ref: ref, goalsRepository: goalsRepository);
    });

class GoalsNotifier extends StateNotifier<AsyncValue<UserGoals>> {
  GoalsNotifier({required this.ref, required this.goalsRepository})
    : super(const AsyncValue.loading()) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      _handleAuthState(next);
    });

    _handleAuthState(ref.read(authStateProvider));
  }

  final Ref ref;
  final GoalsRepository goalsRepository;

  Future<void> loadGoals() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return goalsRepository.getGoals();
    });
  }

  Future<void> updateGoals(UserGoals goals) async {
    final AsyncValue<UserGoals> previousState = state;
    state = const AsyncValue.loading();

    final AsyncValue<UserGoals> result = await AsyncValue.guard(() async {
      return goalsRepository.updateGoals(goals);
    });

    state = result;

    if (result.hasError) {
      state = previousState;
      throw result.error!;
    }
  }

  void resetGoals() {
    state = const AsyncValue.data(UserGoals());
  }

  void _handleAuthState(AuthState authState) {
    if (authState.isChecking) {
      state = const AsyncValue.loading();
      return;
    }

    if (!authState.isAuthenticated) {
      resetGoals();
      return;
    }

    loadGoals();
  }
}
