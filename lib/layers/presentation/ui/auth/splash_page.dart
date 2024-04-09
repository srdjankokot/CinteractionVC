import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/navigation/route.dart';
import '../../cubit/profile/profile_cubit.dart';


class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocProvider<ProfileCubit>(
        create: (context) => getIt.get<ProfileCubit>(),
        child: BlocListener<ProfileCubit, ProfileState>(
          listener: _onUserState,
          child: Scaffold(
            body: Center(
              child: Text(
                'Cinteraction\nFlutter\nApp',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
            ),
          ),
        ),
    );


    return BlocListener<ProfileCubit, ProfileState>(
      listener: _onUserState,
      child: Scaffold(
        body: Center(
          child: Text(
            'Cinteraction\nFlutter\nApp',
            textAlign: TextAlign.center,
            style: context.textTheme.headlineLarge,
          ),
        ),
      ),
    );
  }

  void _onUserState(BuildContext context, ProfileState userState) {
    if (userState is! ProfileLoaded) {
      // User not loaded yet
      return;
    }

    // AppRoute.home.go(context);
    AppRoute.auth.go(context);
  }
}
