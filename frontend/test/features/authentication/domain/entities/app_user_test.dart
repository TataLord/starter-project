import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/app_user.dart';

void main() {
  test('publishes under the chosen display name', () {
    const user = AppUserEntity(
      id: 'journalist-1',
      email: 'alex@example.com',
      displayName: 'Alex Rivera',
    );

    expect(user.authorName, 'Alex Rivera');
  });

  test('falls back to the email local part when no name was chosen', () {
    const user = AppUserEntity(id: 'journalist-1', email: 'alex@example.com');

    expect(user.authorName, 'alex');
  });

  test('ignores a display name that is only whitespace', () {
    const user = AppUserEntity(
      id: 'journalist-1',
      email: 'alex@example.com',
      displayName: '   ',
    );

    expect(user.authorName, 'alex');
  });
}
