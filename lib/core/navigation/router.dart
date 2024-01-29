import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:cinteraction_vc/features/auth/ui/page/auth_page.dart';
import 'package:cinteraction_vc/features/auth/ui/page/splash_page.dart';
import 'package:cinteraction_vc/features/conference/bloc/conference_cubit.dart';
import 'package:cinteraction_vc/features/conference/video_room.dart';
import 'package:cinteraction_vc/features/groups/bloc/groups_cubit.dart';
import 'package:cinteraction_vc/features/groups/repository/groups_repository.dart';
import 'package:cinteraction_vc/features/groups/ui/groups_page.dart';
import 'package:cinteraction_vc/features/meetings/bloc/meetings_cubit.dart';
import 'package:cinteraction_vc/features/meetings/repository/meetings_repository.dart';
import 'package:cinteraction_vc/features/roles/bloc/roles_cubit.dart';
import 'package:cinteraction_vc/features/roles/repository/roles_repository.dart';
import 'package:cinteraction_vc/features/users/ui/users_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_cubit.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/ui/page/forgot_pass_page.dart';
import '../../features/auth/ui/page/reset_pass_send_email.dart';
import '../../features/landing/ui/page/home_page.dart';
import '../../features/profile/repository/profile_repository.dart';
import '../../features/users/bloc/users_cubit.dart';
import '../../features/users/repository/users_repository.dart';

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
            userRepository: context.read<ProfileRepository>(),
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
        child: const VideoRoomPage(room: 06082020, displayName: 'Srdjan'),
      ),
    ),

    GoRoute(
      path: AppRoute.users.path,
      builder: (context, state) {
        // var id = '';
        // if (state.extra != null) id = state.extra! as String;

        final id = state.extra ?? '';
        // final name = state.pageKey['name']!;
        return BlocProvider(
          create: (context) => UsersCubit(
            groupRepository: context.read<GroupsRepository>(),
            usersRepository: context.read<UsersRepository>(),
          ),
          child: UsersPage(groupId: id as String),
        );
      },
    ),

    GoRoute(
      path: AppRoute.groups.path,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => GroupsCubit(
            groupRepository: context.read<GroupsRepository>(),
          ),
          child: const GroupsPage(),
        );
      },
    ),

    GoRoute(
      path: AppRoute.roles.path,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => RolesCubit(
            roleRepository: context.read<RolesRepository>(),
          ),
          child: const GroupsPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoute.meeting.path,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => MeetingCubit(
            meetingRepository: context.read<MeetingRepository>(),
          ),
          child: const GroupsPage(),
        );
      },
    ),
  ],
);
