

import '../../profile/model/user.dart';
import '../../profile/provider/user_mock_provider.dart';

class AuthRepository {
  const AuthRepository({
    required this.userProvider,
  });

  final ProfileProvider userProvider;

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
    return userProvider.triggerLoggedIn();
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
