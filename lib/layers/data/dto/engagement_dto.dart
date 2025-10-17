class CreateEngagementDto {
  final int meetingId;
  final int userId;
  final int moduleId;
  final double value;

  CreateEngagementDto({
    required this.meetingId,
    required this.userId,
    required this.moduleId,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'meeting_id': meetingId,
      'user_id': userId,
      'module_id': moduleId,
      'value': value,
    };
  }

  factory CreateEngagementDto.fromJson(Map<String, dynamic> json) {
    return CreateEngagementDto(
      meetingId: json['meeting_id'] as int,
      userId: json['user_id'] as int,
      moduleId: json['module_id'] as int,
      value: (json['value'] as num).toDouble(),
    );
  }
}

class EngagementResponseDto {
  final String message;

  EngagementResponseDto({
    required this.message,
  });

  factory EngagementResponseDto.fromJson(Map<String, dynamic> json) {
    return EngagementResponseDto(
      message: json['message'] as String,
    );
  }
}
