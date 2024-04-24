import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/entities/meeting.dart';
import 'package:cinteraction_vc/layers/domain/repos/home_repo.dart';

import '../../domain/source/api.dart';

class HomeRepoImpl extends HomeRepo{

  HomeRepoImpl({required Api api,}): _api = api;

  final Api _api;

  @override
  Future<ApiResponse<bool>> scheduleMeeting({required String name, required String description, required String tag, required DateTime date}) async {
    await _api.scheduleMeeting(name: name, description: description, tag: tag, date: date);
    return ApiResponse(response: true);
  }

  @override
  Future<ApiResponse<Meeting?>> getNextMeeting() async {
    return await _api.getNextMeeting();
  }
}