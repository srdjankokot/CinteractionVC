import 'dart:convert';

import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../dto/user_dto.dart';

abstract class LocalStorage {
  Future<bool> saveLoggedUser({required UserDto user});
  User? loadLoggedUser();
}

class LocalStorageImpl extends LocalStorage{

  LocalStorageImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPref = sharedPreferences;

  final SharedPreferences _sharedPref;


  @override
  User? loadLoggedUser() {
    final jsonString = _sharedPref.getString('key');
    var userMap = json.decode(jsonString!);

    return UserDto.fromJson(userMap);

  }

  @override
  Future<bool> saveLoggedUser({required UserDto user}) {
    return _sharedPref.setString('key', json.encode(user.toJson()));
  }

}
