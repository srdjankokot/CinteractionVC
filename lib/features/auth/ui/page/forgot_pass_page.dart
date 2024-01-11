import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:flutter/material.dart';

import '../../../../core/extension/image.dart';
import '../../../../core/ui/input/input_field.dart';
import '../../../../core/ui/widget/responsive.dart';

class ForgotPasswordPage extends StatelessWidget{
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {

    final _emailController = TextEditingController();

    return  Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ResponsiveLayout(
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Image(
                            image: ImageAsset('original_long_logo.png')),

                        Container(
                          width: 230,
                          height: 239,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: ImageAsset('reset_pass_image.png'),
                              fit: BoxFit.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text('Forgot your password?',
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineLarge,
                        ),

                        const SizedBox(height: 33),

                        Text('Let us know your email address and we will email you a password reset link that will allow you to choose a new one.',
                          textAlign: TextAlign.center,
                          style: context.textTheme.labelMedium,
                        ),

                        const SizedBox(height: 38),

                        InputField.email(
                          label: 'Enter your email',
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:() => {
                            AppRoute.forgotPasswordSuccess.push(context)
                          },
                          child: const Text('Reset Password'),
                        ),


                      ],
                    ),
                  ),
                ),
            ));
  }

}