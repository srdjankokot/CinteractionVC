part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState(
      {required this.isLogged,
        required this.loginSuccess,
      required this.registerSuccess,
      required this.isSignUp,
      this.loading,
      required this.isChecked,
      this.errorMessage});

  @override
  List<Object?> get props => [isSignUp, loading, isChecked, isLogged];

  final bool loginSuccess;
  final bool registerSuccess;
  final bool isSignUp;
  final bool isLogged;
  final bool? loading;
  final bool isChecked;
  final String? errorMessage;

  const AuthState.initial({
    bool isLogged = false,
    bool loginSuccess = false,
    bool registerSuccess = false,
    bool isSignUp = false,
    bool loading = false,
    bool isChecked = false,
  }) : this(
    isLogged: isLogged,
            isSignUp: isSignUp,
            loading: loading,
            isChecked: isChecked,
            loginSuccess: loginSuccess,
            registerSuccess: registerSuccess);

  const AuthState.register(
      {
        bool isLogged = false,
        bool loginSuccess = false,
      bool registerSuccess = false,
      bool isSignUp = true,
      bool loading = false,
      bool isChecked = false})
      : this(
      isLogged: isLogged,
            isSignUp: isSignUp,
            loading: loading,
            isChecked: isChecked,
            loginSuccess: loginSuccess,
            registerSuccess: registerSuccess);

  const AuthState.loginSuccess({
    bool isLogged = false,
    bool loginSuccess = true,
    bool registerSuccess = false,
    bool isSignUp = false,
    bool loading = false,
    bool isChecked = false,
  }) : this(
      isLogged: isLogged,
            isSignUp: isSignUp,
            loading: loading,
            isChecked: isChecked,
            loginSuccess: loginSuccess,
            registerSuccess: registerSuccess);

  const AuthState.registerSuccess(
      {
        bool isLogged = false,
        bool loginSuccess = false,
      bool registerSuccess = true,
      bool isSignUp = false,
      bool loading = false,
      bool isChecked = false})
      : this(
      isLogged: isLogged,
            isSignUp: isSignUp,
            loading: loading,
            isChecked: isChecked,
            loginSuccess: loginSuccess,
            registerSuccess: registerSuccess);

  AuthState copyWith(
      {bool? isSignUp, bool? loading, bool? isChecked, String? errorMessage, bool? isLogged}) {
    return AuthState(
      isLogged: isLogged?? this.isLogged,
        isSignUp: isSignUp ?? this.isSignUp,
        loading: loading,
        isChecked: isChecked ?? this.isChecked,
        errorMessage: errorMessage,
        loginSuccess: loginSuccess,
        registerSuccess: registerSuccess);
  }

  AuthState error({String? errorMessage}) {
    return AuthState(
        isLogged: false,
        isSignUp: isSignUp,
        loading: false,
        isChecked: isChecked,
        errorMessage: errorMessage,
        loginSuccess: loginSuccess,
        registerSuccess: registerSuccess);
  }
}

// @immutable
// sealed class AuthState {
//   const AuthState();
// }
//
// class AuthInitial extends AuthState {
//   const AuthInitial();
// }
//
// class AuthRegister extends AuthState {
//   const AuthRegister();
// }
//
// class AuthCheckboxChanged extends AuthState {
//   const AuthCheckboxChanged();
// }
//
// class AuthSuccess extends AuthState {
//   const AuthSuccess({required this.user});
//
//   final User? user;
// }
//
// class RegisterSuccess extends AuthState {
//   const RegisterSuccess({required this.message});
//
//   final String message;
// }
//
// class AuthLoading extends AuthState {
//   const AuthLoading();
// }
//
// class AuthFailure extends AuthState {
//   const AuthFailure({required this.errorMessage});
//
//   final String errorMessage;
// }
//
// class IsLogged extends AuthState {
//   const IsLogged();
// }