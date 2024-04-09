import 'package:cinteraction_vc/core/util/secure_local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/app/injector.dart';
import '../../../core/io/network/models/login_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repos/auth_repo.dart';
import '../../domain/source/api.dart';
import '../dto/user_dto.dart';
import '../source/local/local_storage.dart';

class AuthRepoImpl extends AuthRepo {
  AuthRepoImpl({
    required Api api,
  }) : _api = api;

  final Api _api;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: '86369065781-lpajm2ln4bu8ds7vlb6780rmq0evae3o.apps.googleusercontent.com',
    scopes: scopes,
  );

  /// The scopes required by this application.
  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  @override
  Future<UserDto?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    LoginResponse? response =  await _api.signInEmailPass(email: email, pass: password);
    return _loginToServer(response!.accessToken);
  }

  Future<UserDto?> _loginToServer(String token) async
  {
    await saveAccessToken(token);

    final user = await _api.getUserDetails();

    if (user != null) {
      getIt.get<LocalStorage>().saveLoggedUser(user: user);
      return user;
    }

    return null;
  }

  @override
  Future<User?> signWithFacebookAccount() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      final userInfo = await FacebookAuth.instance.getUserData();

      print('Facebook user: ${userInfo['name']}');

      // final user = _mockUser;
      final user = User(
          id: userInfo['id'],
          name: userInfo['name'],
          email: userInfo['email'],
          imageUrl: 'http://graph.facebook.com/${userInfo['id']}/picture?',
          createdAt: DateTime.now());

      // _userStream.add(user);
      return user;
    } else {
      print('ResultStatus: ${loginResult.status}');
      print('Message: ${loginResult.message}');
    }

    // _userStream.add(null);
    return null;
  }

  @override
  Future<User?> signWithGoogleAccount() async {
    var googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    bool isAuthorized = googleUser != null;
    if (kIsWeb && googleUser != null) {
      isAuthorized = await _googleSignIn.canAccessScopes(scopes);
    }

    if (isAuthorized && googleUser != null) {
      String? accessToken = await _api.socialLogin(provider: 'google', token: googleAuth?.accessToken);
      return _loginToServer(accessToken!);
    }

    return null;
  }

  /// Simulate network delay
  Future<void> _networkDelay() async {
    await Future<void>.delayed(const Duration(seconds: 2));
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
      {required String email, required String password}) {
    // TODO: implement signUpWithEmailAndPassword
    throw UnimplementedError();
  }
}
