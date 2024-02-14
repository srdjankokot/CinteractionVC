

import '../../profile/model/user.dart';
import '../../profile/provider/user_mock_provider.dart';

class AuthRepository {

  const AuthRepository({
    required this.userProvider,
  });

  final ProfileProvider userProvider;

  Stream<String> getErrorStream() {
    return userProvider.getErrorStream();
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return userProvider.triggerLoggedIn();
  }

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return userProvider.loginWithEmailPassword(email, password);
  }

  Future<User?> signWithGoogleAccount() async
  {
    return userProvider.triggerGoogleLoggedIn();
  }

  Future<User?> signWithFacebookAccount() async
  {
    return userProvider.triggerFacebookLoggedIn();
  }
}
