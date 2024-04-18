import 'package:cinteraction_vc/layers/domain/entities/meeting.dart';

import '../../domain/repos/meetings_repo.dart';
import '../../domain/source/api.dart';

class MeetingRepoImpl extends MeetingRepo{

  MeetingRepoImpl({
    required Api api,
  }) : _api = api;

  final Api _api;

  @override
  Future<List<Meeting>?> getListOfPastMeetings() async{
    final meetings = await _api.getMeetings();
    return meetings;
  }

  @override
  Future<List<Meeting>> getListOfScheduledMeetings() {
    // TODO: implement getListOfScheduledMeetings
    throw UnimplementedError();
  }

}