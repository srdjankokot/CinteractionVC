import 'package:cinteraction_vc/layers/data/dto/meetings/meeting_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/meetings/meeting_response.dart';

class MeetingResponseDto extends MeetingResponse {
  MeetingResponseDto(
      {required int lastPage, required List<MeetingDto> meetings})
      : super(meetings: meetings, lastPage: lastPage);

  @override
  factory MeetingResponseDto.fromJson(Map<String, dynamic> json) {
    return MeetingResponseDto(
        meetings: List<MeetingDto>.from(json['data'].map((e) => MeetingDto.fromJson(e))),
        lastPage: json['last_page'] as int);
  }
}
