import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/repos/home_repo.dart';

class ScheduleMeetingUseCase{
  ScheduleMeetingUseCase({required this.repo});
  final HomeRepo repo;

  Future<ApiResponse<String>> call(String name, String description, String tag, DateTime date) {
    return repo.scheduleMeeting(name: name, description: description, tag: tag, date: date);
  }
}