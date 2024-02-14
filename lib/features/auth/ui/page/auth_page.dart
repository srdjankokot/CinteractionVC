import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:cinteraction_vc/core/extension/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/navigation/route.dart';
import '../../../../core/ui/input/input_field.dart';
import '../../../../core/ui/widget/labeled_text_button.dart';
import '../../../../core/ui/widget/loading_overlay.dart';
import '../../../../core/ui/widget/responsive.dart';
import '../../bloc/auth_cubit.dart';

import 'package:http/http.dart' as http;

// /// The scopes required by this application.
// // #docregion Initialize
// const List<String> scopes = <String>[
//   'email',
//   'https://www.googleapis.com/auth/contacts.readonly',
// ];
//
// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '86369065781-opekj9mf25mr923bg7mm7fe535istken.apps.googleusercontent.com',
//   scopes: scopes,
// );

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    // context.read<AuthCubit>().getAccess();
  }


  @override
  Widget build(BuildContext ctx) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: _onAuthState,
      builder: (context, state) {
        final Widget body;
        if (context.isWide) {
          body = Material(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: double.maxFinite,
                    alignment: Alignment.centerRight,

                    child: imageSVGAsset('original_long_logo'),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(

                            child: const Image(
                              image: ImageAsset('login_image.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(

                            alignment: Alignment.center,
                            child: Container(

                              height: double.maxFinite,

                              constraints: const BoxConstraints(minWidth: 200, maxWidth: 550),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isSignUp ? 'Sign up' : 'Log in',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.headlineLarge,
                                  ),
                                  const SizedBox(height: 33),

                                  Visibility(
                                      visible: _isSignUp,
                                      child: Column(
                                        children: [
                                          InputField.name(
                                              label: 'Enter your full name',
                                              controller: _nameController,
                                              textInputAction:
                                                  TextInputAction.next),
                                          const SizedBox(height: 16),
                                        ],
                                      )),

                                  InputField.email(
                                    label: 'Enter your email',
                                    controller: _emailController,
                                  ),

                                  const SizedBox(height: 16),
                                  InputField.password(
                                    label: 'Enter your password',
                                    controller: _passwordController,
                                    textInputAction: _isSignUp
                                        ? TextInputAction.next
                                        : TextInputAction.done,
                                    onFieldSubmitted:
                                        _isSignUp ? null : (_) => _submit(),
                                  ),

                                  Visibility(
                                      visible: _isSignUp,
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 16),
                                          InputField(
                                            label: 'Confirm password',
                                            controller:
                                                _confirmPasswordController,
                                            textInputAction:
                                                TextInputAction.done,
                                            onFieldSubmitted: (_) => _submit(),
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            autofillHints: const [
                                              AutofillHints.password
                                            ],
                                            validator: (confirmPassword) {
                                              if (confirmPassword == null ||
                                                  confirmPassword.isEmpty) {
                                                return 'Required';
                                              }

                                              if (_passwordController.text !=
                                                  confirmPassword) {
                                                return 'Password doesn\'t match';
                                              }
                                            },
                                          ),
                                        ],
                                      )),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTileTheme(
                                          horizontalTitleGap: 0.0,
                                          child: CheckboxListTile(
                                            contentPadding: EdgeInsets.zero,
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            title: _isSignUp
                                                ? const Text(
                                                    'I agree to the Terms of Service')
                                                : const Text('Remember me'),
                                            value: timeDilation != 1.0,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                timeDilation =
                                                    value! ? 3.0 : 1.0;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: !_isSignUp,
                                        child: LabeledTextButton(
                                          label: 'Forgot password',
                                          action: '',
                                          onTap: () => {
                                            AppRoute.forgotPassword
                                                .push(context)
                                          },
                                        ),
                                      )
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: ElevatedButton(
                                      onPressed: _submit,
                                      child: Text(
                                          _isSignUp ? 'Register' : 'Log In'),
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  // const Spacer(),

                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: const Text('Or login with'),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        height: 60,
                                        child: OutlinedButton(
                                            onPressed: () => {
                                                  context
                                                      .read<AuthCubit>()
                                                      .signInWithGoogle()
                                                },
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  width: 1,
                                                  color: Color(0xFFBDBDBD)),
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFBDBDBD)),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                            ),
                                            child:
                                                imageSVGAsset('google_logo')),
                                      ),
                                      const SizedBox(width: 34),
                                      SizedBox(
                                        width: 70,
                                        height: 60,
                                        child: OutlinedButton(
                                            onPressed: () => {
                                                  context
                                                      .read<AuthCubit>()
                                                      .signInWithFacebook()
                                                },
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  width: 1,
                                                  color: Color(0xFFBDBDBD)),
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFBDBDBD)),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                            ),
                                            child: imageSVGAsset('fb_logo')),
                                      )
                                    ],
                                  ),

                                  Text(_contactText),
                                  const SizedBox(height: 8),
                                  LabeledTextButton(
                                    label: _isSignUp
                                        ? 'Already have an account?'
                                        : 'Don’t have an account?',
                                    action: _isSignUp ? 'Sign in' : 'Sign up',
                                    onTap: () => _changeLayout(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          body = SafeArea(

              child: ResponsiveLayout(
                body: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      imageSVGAsset('original_long_logo') as Widget,

                      Container(
                        width: 230,
                        height: 239,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: ImageAsset('login_image.png'),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isSignUp ? 'Sign up' : 'Log in',
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 33),

                      Visibility(
                          visible: _isSignUp,
                          child: Column(
                            children: [
                              InputField.name(
                                  label: 'Enter your full name',
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                            ],
                          )),

                      InputField.email(
                        label: 'Enter your email',
                        controller: _emailController,
                      ),

                      const SizedBox(height: 16),
                      InputField.password(
                        label: 'Enter your password',
                        controller: _passwordController,
                        textInputAction:
                            _isSignUp ? TextInputAction.next : TextInputAction.done,
                        onFieldSubmitted: _isSignUp ? null : (_) => _submit(),
                      ),

                      Visibility(
                          visible: _isSignUp,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              InputField(
                                label: 'Confirm password',
                                controller: _confirmPasswordController,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                keyboardType: TextInputType.visiblePassword,
                                autofillHints: const [AutofillHints.password],
                                validator: (confirmPassword) {
                                  if (confirmPassword == null ||
                                      confirmPassword.isEmpty) {
                                    return 'Required';
                                  }

                                  if (_passwordController.text != confirmPassword) {
                                    return 'Password doesn\'t match';
                                  }
                                },
                              ),
                            ],
                          )),

                      Row(
                        children: [
                          Expanded(
                            child: ListTileTheme(
                              horizontalTitleGap: 0.0,
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                                title: _isSignUp
                                    ? const Text('I agree to the Terms of Service')
                                    : const Text('Remember me'),
                                value: timeDilation != 1.0,
                                onChanged: (bool? value) {
                                  setState(() {
                                    timeDilation = value! ? 3.0 : 1.0;
                                  });
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !_isSignUp,
                            child: LabeledTextButton(
                              label: 'Forgot password',
                              action: '',
                              onTap: () => {AppRoute.forgotPassword.push(context)},
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isSignUp ? 'Register' : 'Log In'),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 16),
                      // const Spacer(),

                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Container(
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            child: const Text('Or login with'),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 60,
                            child: OutlinedButton(
                                onPressed: () =>
                                    {context.read<AuthCubit>().signInWithGoogle()},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 1, color: Color(0xFFBDBDBD)),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1, color: Color(0xFFBDBDBD)),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: imageSVGAsset('google_logo')),
                          ),
                          const SizedBox(width: 34),
                          SizedBox(
                            width: 70,
                            height: 60,
                            child: OutlinedButton(
                                onPressed: () => {
                                      context.read<AuthCubit>().signInWithFacebook()
                                    },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 1, color: Color(0xFFBDBDBD)),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1, color: Color(0xFFBDBDBD)),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: imageSVGAsset('fb_logo')),
                          )
                        ],
                      ),

                      Text(_contactText),
                      const SizedBox(height: 8),
                      LabeledTextButton(
                        label: _isSignUp
                            ? 'Already have an account?'
                            : 'Don’t have an account?',
                        action: _isSignUp ? 'Sign in' : 'Sign up',
                        onTap: () => _changeLayout(),
                      ),
                    ],
                  ),
                ),
            ),
          );
        }

        return Scaffold(
          body: LoadingOverlay(
              loading: state is AuthLoading,
              child: Container(
                color: Colors.white,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: state is IsLogged? Center(child: Text('User is already logged in'),):body,
                  ),
                ),
              )),
        );
      },
    );
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state is AuthFailure) {
      print(state.errorMessage);

      // final snackBar = SnackBar(
      //   content: const Text('Yay! A SnackBar!'),
      //   action: SnackBarAction(
      //     label: 'Undo',
      //     onPressed: () {
      //       // Some code to undo the change.
      //     },
      //   ),
      // );
      //
      // // Find the ScaffoldMessenger in the widget tree
      // // and use it to show a SnackBar.
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //

      context.showSnackBarMessage(
        state.errorMessage,
        isError: true,
      );
      return;
    }

    if (state is AuthSuccess) {
      if (state.user != null) {
        AppRoute.home.go(context);
      }
    }
  }

  void _changeLayout() {
    setState(() => _isSignUp = !_isSignUp);
    _formKey.currentState?.reset();

    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
    _emailController.clear();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.closeKeyboard();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isSignUp) {
      context.read<AuthCubit>().signUpWithEmailAndPassword(
            email: email,
            password: password,
          );
    } else {
      context.read<AuthCubit>().signInWithEmailAndPassword(
            email: email,
            password: password,
          );
    }
  }
}
