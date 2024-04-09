
import '../../../core/io/network/models/login_response.dart';
import '../../data/dto/user_dto.dart';
import '../entities/user.dart';

abstract class AuthRepo
{
  const AuthRepo();

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserDto?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<User?> signWithGoogleAccount();

  Future<User?> signWithFacebookAccount();
}