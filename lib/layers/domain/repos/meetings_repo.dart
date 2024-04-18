import 'package:cinteraction_vc/layers/domain/entities/meeting.dart';

abstract class MeetingRepo {
  MeetingRepo();

  Future<List<Meeting>?> getListOfPastMeetings();
  Future<List<Meeting>?> getListOfScheduledMeetings();
}
