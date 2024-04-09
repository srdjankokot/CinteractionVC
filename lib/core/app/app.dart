import 'package:cinteraction_vc/core/app/style.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/conference/conference_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../layers/presentation/cubit/profile/profile_cubit.dart';
import '../navigation/router.dart';
import 'injector.dart';

class CinteractionFlutterApp extends StatelessWidget {
  const CinteractionFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
          title: 'Cinteraction',
          theme: lightTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: router,

    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (context) => getIt.get<ProfileCubit>(),
        ),

        BlocProvider<ConferenceCubit>(
          create: (context) => getIt.get<ConferenceCubit>(),
        ),




        // BlocProvider<UsersCubit>(
        //   create: (context) => UsersCubit(
        //     groupRepository: context.read<GroupsRepository>(),
        //     usersRepository: context.read<UsersRepository>(),
        //   ),
        // ),
        //
        //
        //
        // BlocProvider<GroupsCubit>(
        //   create: (context) => GroupsCubit(
        //     groupRepository: context.read<GroupsRepository>(),
        //   ),
        // ),
        //
        //
        //
        // BlocProvider<RolesCubit>(
        //   create: (context) => RolesCubit(
        //     roleRepository: context.read<RolesRepository>(),
        //   ),
        // ),
        //
        // BlocProvider<MeetingCubit>(
        //   create: (context) => MeetingCubit(
        //     meetingRepository: context.read<MeetingRepository>(),
        //   ),
        // ),
        //
        // BlocProvider<ConferenceCubit>(
        //   create: (context) => ConferenceCubit(
        //       conferenceRepository: context.read<ConferenceRepository>(),
        //       roomId: 1234,
        //       displayName: ''
        //   ),
        // ),
      ],
      child: MaterialApp.router(
        title: 'Cinteraction',
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );

    return  MaterialApp.router(
        title: 'Cinteraction',
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
    );
  }
}
