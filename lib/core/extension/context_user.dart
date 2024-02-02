import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/profile/bloc/profile_cubit.dart';
import '../../features/profile/model/user.dart';



extension BuildContextUserExt on BuildContext {
  User? get watchCurrentUser {
    final userState = watch<ProfileCubit>().state;
    if (userState is! ProfileLoaded) {
      return null;
    }

    return userState.user;
  }

  User? get getCurrentUser {
    final userState = read<ProfileCubit>().state;
    if (userState is! ProfileLoaded) {
      return null;
    }

    return userState.user;
  }
}
