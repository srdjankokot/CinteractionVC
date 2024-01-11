import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';

import '../../../../core/extension/image.dart';
import '../../../../core/ui/input/input_field.dart';
import '../../../../core/ui/widget/responsive.dart';

class ResetPassEmailPage extends StatelessWidget{
  const ResetPassEmailPage({super.key});

  @override
  Widget build(BuildContext context) {


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

                  Text('Check your mail',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineLarge,
                  ),

                  const SizedBox(height: 33),

                  Text('We have sent a password recover instructions to your email.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelMedium,
                  ),

                  const SizedBox(height: 38),

                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Ok'),
                  ),


                ],
              ),
            ),
          ),
        ));
  }

  void _submit() {

  }
}