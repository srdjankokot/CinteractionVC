import 'package:cinteraction_vc/core/app/injector.dart';

import '../../../data/dto/user_dto.dart';
import '../../repos/auth_repo.dart';


class SignUpWithEmailAndPassword{
   SignUpWithEmailAndPassword();

  final AuthRepo _repo = getIt.get<AuthRepo>();

  Future<UserDto?> call(String email, String password) async{
    return await _repo.signInWithEmailAndPassword(email: email, password: password);
  }
}