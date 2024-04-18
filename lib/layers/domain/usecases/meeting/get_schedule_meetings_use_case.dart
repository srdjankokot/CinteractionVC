import '../../entities/meeting.dart';
import '../../repos/meetings_repo.dart';

class GetScheduleMeetings{
  final MeetingRepo repo;
  GetScheduleMeetings({required this.repo});

  Future<List<Meeting>?> call() {
    return repo.getListOfScheduledMeetings();
  }
}