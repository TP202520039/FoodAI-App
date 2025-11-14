// ignore_for_file: unnecessary_this

class FoodAiUser {
  int? id;
  String? firebaseUid;
  String? email;
  String? displayName;
  String? photoUrl;
  String? provider;
  bool? isActive;

  FoodAiUser(
      {this.id,
      this.firebaseUid,
      this.email,
      this.displayName,
      this.photoUrl,
      this.provider,
      this.isActive});
}