
import '../../../../../core/app/injector.dart';
import '../../entities/user.dart';
import '../../repos/auth_repo.dart';

class SignUpWithGoogle{
   SignUpWithGoogle();

   final AuthRepo _repo = getIt.get<AuthRepo>();

  Future<User?> call() async{
    return await _repo.signWithGoogleAccount();
  }
}