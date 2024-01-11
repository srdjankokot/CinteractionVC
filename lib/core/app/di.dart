import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/repository/auth_repository.dart';
import '../../features/profile/bloc/user_cubit.dart';
import '../../features/profile/repository/user_repository.dart';
import '../../features/profile/provider/user_mock_provider.dart';

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
        RepositoryProvider<UserProvider>(
          create: (context) => UserProvider(),
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
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(
            userProvider: context.read<UserProvider>(),
          ),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            userProvider: context.read<UserProvider>(),
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
        BlocProvider<UserCubit>(
          create: (context) => UserCubit(
            userRepository: context.read<UserRepository>(),
          ),
        ),
      ],
      child: child,
    );
  }
}