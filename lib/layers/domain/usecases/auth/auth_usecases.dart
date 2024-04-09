
import 'package:cinteraction_vc/layers/domain/usecases/auth/sign_up_with_email_and_pass.dart';
import 'package:cinteraction_vc/layers/domain/usecases/auth/sign_up_with_google.dart';

class AuthUseCases {
   SignUpWithGoogle signUpWithGoogle = SignUpWithGoogle();
   SignUpWithEmailAndPassword signUpWithEmailAndPassword = SignUpWithEmailAndPassword();
}
