import '../entities/api_response.dart';
import '../entities/meetings/meeting.dart';

abstract class HomeRepo
{
  Future<ApiResponse<String>> scheduleMeeting({
    required String name,
    required String description,
    required String tag,
    required DateTime date,
  });

  Future<ApiResponse<Meeting?>> getNextMeeting();
}
