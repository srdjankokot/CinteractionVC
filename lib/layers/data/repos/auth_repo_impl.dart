import 'package:cinteraction_vc/core/util/secure_local_storage.dart';
import 'package:cinteraction_vc/layers/domain/entities/api_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/app/injector.dart';
import '../../../core/io/network/models/login_response.dart';
import '../../domain/entities/api_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repos/auth_repo.dart';
import '../../domain/source/api.dart';
import '../dto/user_dto.dart';
import '../source/local/local_storage.dart';

/// The scopes required by this application.
const List<String> scopes = <String>['email', 'profile', 'openid'];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '86369065781-lpajm2ln4bu8ds7vlb6780rmq0evae3o.apps.googleusercontent.com',
  scopes: scopes,
);

class AuthRepoImpl extends AuthRepo {
  AuthRepoImpl({
    required Api api,
  }) : _api = api;

  final Api _api;

  @override
  Future<ApiResponse<UserDto?>> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    var response = await _api.signInEmailPass(email: email, pass: password);
    if (response.error == null) {
      await saveAccessToken(response.response!.accessToken);
      return getUserDetails();
    }
    return ApiResponse(error: response.error);
  }

  @override
  Future<ApiResponse<UserDto?>> signWithFacebookAccount() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      final userInfo = await FacebookAuth.instance.getUserData();

      print('Facebook user: ${userInfo['name']}');

      // final user = _mockUser;
      final user = UserDto(
        id: userInfo['id'],
        name: userInfo['name'],
        email: userInfo['email'],
        imageUrl: 'http://graph.facebook.com/${userInfo['id']}/picture?',
      );

      // _userStream.add(user);
      return ApiResponse(response: user);
    } else {
      print('ResultStatus: ${loginResult.status}');
      print('Message: ${loginResult.message}');
    }

    // _userStream.add(null);
    return ApiResponse(
        error: ApiError(errorCode: 0, errorMessage: 'Unknown Error'));
  }

  @override
  Future<ApiResponse<UserDto?>> signWithGoogleAccount() async {
    var googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    bool isAuthorized = googleUser != null;
    if (kIsWeb && googleUser != null) {
      isAuthorized = await _googleSignIn.canAccessScopes(scopes);
    }

    if (isAuthorized && googleUser != null) {
      String? accessToken = await _api.socialLogin(
          provider: 'google', token: googleAuth?.accessToken);
      await saveAccessToken(accessToken!);
      return getUserDetails();
    }

    return ApiResponse(
        error: ApiError(errorCode: 0, errorMessage: 'Unknown Error'));
  }

  /// Simulate network delay
  Future<void> _networkDelay() async {
    await Future<void>.delayed(const Duration(seconds: 2));
  }

  @override
  Future<ApiResponse<String>> signUpWithEmailAndPassword(
      {required String email,
      required String password,
      required String name,
      required bool terms}) async {
    return await _api.signUpEmailPass(
        email: email, pass: password, name: name, terms: terms);
  }

  @override
  Future<ApiResponse<UserDto?>> getUserDetails() async {
    // await saveAccessToken(token);

    final response = await _api.getUserDetails();

    if (response.error == null) {
      var user = response.response;
      getIt.get<LocalStorage>().saveLoggedUser(user: user!);
      return response;
    }

    return ApiResponse(error: response.error);
  }

  @override
  Future<ApiResponse<bool?>> resetPassword({required String email}) async {
    return await _api.resetPassword(email: email);
  }

  @override
  Future<ApiResponse<bool?>> setNewPassword(
      {required String email,
      required String token,
      required String newPassword}) async {
    return await _api.setNewPassword(
        email: email, token: token, newPassword: newPassword);
  }
}
