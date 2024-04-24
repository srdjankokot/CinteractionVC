import 'package:cinteraction_vc/layers/domain/entities/meeting.dart';

import '../entities/api_response.dart';

abstract class MeetingRepo {
  MeetingRepo();

  Future<List<Meeting>?> getListOfPastMeetings();
  Future<ApiResponse<List<Meeting>?>>  getListOfScheduledMeetings();
}
