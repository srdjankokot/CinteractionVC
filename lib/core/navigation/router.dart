import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:cinteraction_vc/features/auth/ui/page/auth_page.dart';
import 'package:cinteraction_vc/features/auth/ui/page/splash_page.dart';
import 'package:cinteraction_vc/features/conference/bloc/conference_cubit.dart';
import 'package:cinteraction_vc/features/conference/video_room.dart';
import 'package:cinteraction_vc/features/home/ui/page/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_cubit.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/ui/page/forgot_pass_page.dart';
import '../../features/auth/ui/page/reset_pass_send_email.dart';
import '../../features/home/profile/repository/user_repository.dart';


final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: AppRoute.splash.path,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoute.home.path,
      builder: (context, state) => const HomePage(),
    ),


    // GoRoute(
    //   path: AppRoute.settings.path,
    //   builder: (context, state) => const SettingsPage(),
    // ),
    GoRoute(
      path: AppRoute.auth.path,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => AuthCubit(
            userRepository: context.read<UserRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
          child: const AuthPage(),
        );
      },
    ),

    GoRoute(
      path: AppRoute.forgotPassword.path,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoute.forgotPasswordSuccess.path,
      builder: (context, state) => const ResetPassEmailPage(),
    ),

    GoRoute(
      path: AppRoute.meeting.path,
      // builder: (context, state) => const VideoRoomPage(room: 123456, displayName: 'Srdjan'),
      builder: (context, state) => BlocProvider(
        create: (context) => ConferenceCubit(),
        child: const VideoRoomPage(room: 123456, displayName: 'Srdjan'),
      ),
    ),


  ],
);
