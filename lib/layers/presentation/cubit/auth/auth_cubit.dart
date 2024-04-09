import 'dart:async';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logger/loggy_types.dart';
import '../../../../../core/util/secure_local_storage.dart';
import '../../../data/source/local/local_storage.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/auth_usecases.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> with BlocLoggy {
  AuthCubit({
    required AuthUseCases authUseCases,
  })  : _authUseCases = authUseCases,
        super(const AuthInitial());


  final AuthUseCases _authUseCases;


  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
      emit(const AuthFailure(errorMessage: 'Not implemented yet'));
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      final user = await _authUseCases.signUpWithEmailAndPassword(email, password);
      if (user != null) {
        getIt.get<LocalStorage>().saveLoggedUser(user: user);
        emit(AuthSuccess(user: user));
      } else {
        emit(const AuthFailure(errorMessage: 'errorMessage'));
      }
    } catch (e, s) {
      emit(AuthFailure(errorMessage: 'errorMessage ${e.toString()}'));
    }

  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final user = await _authUseCases.signUpWithGoogle();
      emit(AuthSuccess(user: user));
    } catch (e, s) {
      loggy.error('signInWithGoogle error', e, s);
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

  Future<void> signInWithFacebook() async {
      emit(const AuthFailure(errorMessage: 'Not implemented yet'));
  }
}
