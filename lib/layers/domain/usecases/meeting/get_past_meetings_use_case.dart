import '../../entities/api_response.dart';
import '../../entities/meeting.dart';
import '../../repos/meetings_repo.dart';

class GetPastMeetingsUseCase{

  GetPastMeetingsUseCase({required this.repo});
  final MeetingRepo repo;


  Future<ApiResponse<List<Meeting>?>> call() {
    return repo.getListOfPastMeetings();
  }
}