import 'package:cinteraction_vc/layers/domain/entities/meeting.dart';

import '../../domain/entities/api_response.dart';
import '../../domain/repos/meetings_repo.dart';
import '../../domain/source/api.dart';

class MeetingRepoImpl extends MeetingRepo{

  MeetingRepoImpl({
    required Api api,
  }) : _api = api;

  final Api _api;

  @override
  Future<ApiResponse<List<Meeting>?>> getListOfPastMeetings() async{
    final meetings = await _api.getMeetings();
    return meetings;
  }

  @override
  Future<ApiResponse<List<Meeting>?>>  getListOfScheduledMeetings() async{
    final meetings = await _api.getScheduledMeetings();
    return meetings;
  }

}