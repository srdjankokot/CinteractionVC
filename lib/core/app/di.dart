import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/features/conference/bloc/conference_cubit.dart';
import 'package:cinteraction_vc/features/conference/provider/conference_provider.dart';
import 'package:cinteraction_vc/features/conference/repository/conference_repository.dart';
import 'package:cinteraction_vc/features/groups/bloc/groups_cubit.dart';
import 'package:cinteraction_vc/features/groups/provider/groups_provider.dart';
import 'package:cinteraction_vc/features/groups/repository/groups_repository.dart';
import 'package:cinteraction_vc/features/meetings/bloc/meetings_cubit.dart';
import 'package:cinteraction_vc/features/meetings/provider/meetings_provider.dart';
import 'package:cinteraction_vc/features/meetings/repository/meetings_repository.dart';
import 'package:cinteraction_vc/features/roles/bloc/roles_cubit.dart';
import 'package:cinteraction_vc/features/roles/provider/roles_provider.dart';
import 'package:cinteraction_vc/features/roles/repository/roles_repository.dart';
import 'package:cinteraction_vc/features/users/repository/users_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/repository/auth_repository.dart';
import '../../features/profile/bloc/profile_cubit.dart';
import '../../features/profile/provider/user_mock_provider.dart';
import '../../features/profile/repository/profile_repository.dart';
import '../../features/users/bloc/users_cubit.dart';
import '../../features/users/provider/users_provider.dart';

class DI extends StatelessWidget {
  const DI({
    required this.child,
    super.key,
  });

  final Widget child;


  @override
  Widget build(BuildContext context) {
    return _ProviderDI(
      child: _RepositoryDI(
        child: _BlocDI(
          child: child,
        ),
      ),
    );
  }
}

class _ProviderDI extends StatelessWidget {
  const _ProviderDI({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProfileProvider>(
          create: (context) => ProfileProvider(),
        ),

        RepositoryProvider<UsersProvider>(
          create: (context) => UsersProvider(),
        ),


        RepositoryProvider<GroupsProvider>(
          create: (context) => GroupsProvider(),
        ),

        RepositoryProvider<RolesProvider>(
          create: (context) => RolesProvider(),
        ),
        RepositoryProvider<MeetingProvider>(
          create: (context) => MeetingProvider(),
        ),

        RepositoryProvider<ConferenceProvider>(
          create: (context) => ConferenceProvider(),
        ),
      ],
      child: child,
    );
  }
}

class _RepositoryDI extends StatelessWidget {
  const _RepositoryDI({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepository(
            profileProvider: context.read<ProfileProvider>(),
          ),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            userProvider: context.read<ProfileProvider>(),
          ),
        ),

        RepositoryProvider<UsersRepository>(
          create: (context) => UsersRepository(
            usersProvider: context.read<UsersProvider>(),
          ),
        ),
        RepositoryProvider<GroupsRepository>(
          create: (context) => GroupsRepository(
            groupsProvider: context.read<GroupsProvider>(),
          ),
        ),

        RepositoryProvider<RolesRepository>(
          create: (context) => RolesRepository(
            rolesProvider: context.read<RolesProvider>(),
          ),
        ),
        RepositoryProvider<MeetingRepository>(
          create: (context) => MeetingRepository(
            meetingProvider: context.read<MeetingProvider>(),
          ),
        ),

        RepositoryProvider<ConferenceRepository>(
          create: (context) => ConferenceRepository(
            provider: context.read<ConferenceProvider>(),
          ),
        ),

      ],
      child: child,
    );
  }
}

class _BlocDI extends StatelessWidget {
  const _BlocDI({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            userRepository: context.read<ProfileRepository>(),
          ),
        ),

        BlocProvider<UsersCubit>(
          create: (context) => UsersCubit(
              groupRepository: context.read<GroupsRepository>(),
              usersRepository: context.read<UsersRepository>(),
          ),
        ),



        BlocProvider<GroupsCubit>(
          create: (context) => GroupsCubit(
            groupRepository: context.read<GroupsRepository>(),
          ),
        ),



        BlocProvider<RolesCubit>(
          create: (context) => RolesCubit(
            roleRepository: context.read<RolesRepository>(),
          ),
        ),

        BlocProvider<MeetingCubit>(
          create: (context) => MeetingCubit(
            meetingRepository: context.read<MeetingRepository>(),
          ),
        ),

        BlocProvider<ConferenceCubit>(
          create: (context) => ConferenceCubit(
            conferenceRepository: context.read<ConferenceRepository>(),
            roomId: 1234,
            displayName: ''
          ),
        ),
      ],
      child: child,
    );
  }
}