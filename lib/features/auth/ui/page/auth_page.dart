import 'dart:async';
import 'dart:convert';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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

//     _googleSignIn.onCurrentUserChanged
//         .listen((GoogleSignInAccount? account) async {
// // #docregion CanAccessScopes
//       // In mobile, being authenticated means being authorized...
//       bool isAuthorized = account != null;
//       // However, on web...
//       if (kIsWeb && account != null) {
//         isAuthorized = await _googleSignIn.canAccessScopes(scopes);
//       }
// // #enddocregion CanAccessScopes
//
//       setState(() {
//         _currentUser = account;
//         _isAuthorized = isAuthorized;
//       });
//
//       // Now that we know that the user can access the required scopes, the app
//       // can call the REST API.
//       if (isAuthorized) {
//         unawaited(_handleGetContact(account!));
//         // _handleSignOut();
//       }
//     });
//
//     // In the web, _googleSignIn.signInSilently() triggers the One Tap UX.
//     //
//     // It is recommended by Google Identity Services to render both the One Tap UX
//     // and the Google Sign In button together to "reduce friction and improve
//     // sign-in rates" ([docs](https://developers.google.com/identity/gsi/web/guides/display-button#html)).
//     _googleSignIn.signInSilently();
  }

  // Future<void> _handleSignOut() => _googleSignIn.disconnect();

  // This is the on-click handler for the Sign In button that is rendered by Flutter.
  //
  // On the web, the on-click handler of the Sign In button is owned by the JS
  // SDK, so this method can be considered mobile only.
  // #docregion SignIn
  // Future<void> _handleSignIn() async {
  //   try {
  //     await _googleSignIn.signIn();
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  // #enddocregion SignIn

  // Prompts the user to authorize `scopes`.
  //
  // This action is **required** in platforms that don't perform Authentication
  // and Authorization at the same time (like the web).
  //
  // On the web, this must be called from an user interaction (button click).
  // #docregion RequestScopes
  // Future<void> _handleAuthorizeScopes() async {
  //   final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
  //   // #enddocregion RequestScopes
  //   setState(() {
  //     _isAuthorized = isAuthorized;
  //   });
  //   // #docregion RequestScopes
  //   if (isAuthorized) {
  //     unawaited(_handleGetContact(_currentUser!));
  //   }
  //   // #enddocregion RequestScopes
  // }
  //
  // // Calls the People API REST endpoint for the signed-in user to retrieve information.
  // Future<void> _handleGetContact(GoogleSignInAccount user) async {
  //   setState(() {
  //     _contactText = 'Loading contact info...';
  //   });
  //
  //   print('You are logged in as ${user.displayName}');
  //
  //   setState(() {
  //     _contactText = 'You are logged in as ${user.displayName}';
  //   });
  //
  //   // final http.Response response = await http.get(
  //   //   Uri.parse('https://people.googleapis.com/v1/people/me/connections'
  //   //       '?requestMask.includeField=person.names'),
  //   //   headers: await user.authHeaders,
  //   // );
  //   // if (response.statusCode != 200) {
  //   //   setState(() {
  //   //     _contactText = 'People API gave a ${response.statusCode} '
  //   //         'response. Check logs for details.';
  //   //   });
  //   //   print('People API ${response.statusCode} response: ${response.body}');
  //   //   return;
  //   // }
  //   // final Map<String, dynamic> data =
  //   // json.decode(response.body) as Map<String, dynamic>;
  //   // final String? namedContact = _pickFirstNamedContact(data);
  //   // setState(() {
  //   //   if (namedContact != null) {
  //   //     _contactText = 'I see you know $namedContact!';
  //   //   } else {
  //   //     _contactText = 'No contacts to display.';
  //   //   }
  //   // });
  // }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext ctx) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: _onAuthState,
      builder: (context, state) {
        return LoadingOverlay(
            loading: state is AuthLoading,
            child: Scaffold(
                body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ResponsiveLayout(
                  body: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Image(
                            image: ImageAsset('original_long_logo.png')),

                        Container(
                          width: 230,
                          height: 239,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: ImageAsset('login_image.png'),
                              fit: BoxFit.none,
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
                          textInputAction: _isSignUp
                              ? TextInputAction.next
                              : TextInputAction.done,
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
                                onTap: () =>
                                    {AppRoute.forgotPassword.push(context)},
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isSignUp ? 'Register' : 'Log In'),
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
                            Container(
                                padding: const EdgeInsets.all(12),
                                width: 62.30,
                                height: 52.21,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1, color: Color(0xFFBDBDBD)),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => {
                                    context.read<AuthCubit>().signInWithGoogle()
                                  }, // needed
                                  child: const Image(
                                    image: ImageAsset('google_log.png'),
                                    fit: BoxFit.scaleDown,
                                  ),
                                )),
                            const SizedBox(width: 34),
                            Container(
                                padding: const EdgeInsets.all(12),
                                width: 62.30,
                                height: 52.21,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1, color: Color(0xFFBDBDBD)),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => {
                                    context.read<AuthCubit>().signInWithFacebook()
                                  }
                                  , // needed
                                  child: const Image(
                                    image: ImageAsset('fb_logo.png'),
                                    fit: BoxFit.scaleDown,
                                  ),
                                )),
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
            )));
      },
    );
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state is AuthFailure) {
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
