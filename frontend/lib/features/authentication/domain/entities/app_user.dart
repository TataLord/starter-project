import 'package:equatable/equatable.dart';

/// A person signed in to the app.
///
/// [id] is the backend's user id, and it is what `firestore.rules` compares
/// against an article's `userId`: it is the identity that owns everything a
/// journalist writes.
class AppUserEntity extends Equatable {
  final String id;
  final String email;

  /// Name shown to readers as the article's author. It falls back to the part
  /// of the email before the `@` when the person never chose one.
  final String displayName;

  const AppUserEntity({
    required this.id,
    required this.email,
    this.displayName = '',
  });

  AppUserEntity copyWith({
    String ? id,
    String ? email,
    String ? displayName,
  }) {
    return AppUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  /// Name to publish articles under.
  String get authorName {
    if (displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    final localPart = email.split('@').first;

    return localPart.isEmpty ? email : localPart;
  }

  @override
  List<Object ?> get props => [id, email, displayName];
}
