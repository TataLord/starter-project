import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';

/// Data layer view of [AppUserEntity], built from a Firebase Auth [User].
class AppUserModel extends AppUserEntity {
  const AppUserModel({
    required super.id,
    required super.email,
    super.displayName,
  });

  factory AppUserModel.fromFirebaseUser(User user) {
    return AppUserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }

  AppUserEntity toEntity() {
    return AppUserEntity(id: id, email: email, displayName: displayName);
  }
}
