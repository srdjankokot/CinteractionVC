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

class EngagementTotalAverageDto {
  final List<EngagementDataPoint> totalAttentionAverage;
  final List<UserEngagementData> usersAverage;

  EngagementTotalAverageDto({
    required this.totalAttentionAverage,
    required this.usersAverage,
  });

  factory EngagementTotalAverageDto.fromJson(List<dynamic> json) {
    // Parse raw data and group by time slots
    final rawData = json
        .map((item) => RawEngagementData.fromJson(item as Map<String, dynamic>))
        .toList();

    // Group by user
    final Map<int, List<RawEngagementData>> userData = {};
    for (final data in rawData) {
      userData.putIfAbsent(data.userId, () => []).add(data);
    }

    // Calculate time slots (every 5 minutes)
    final timeSlots = _calculateTimeSlots(rawData);

    // Calculate averages for each time slot
    final totalAverages = <EngagementDataPoint>[];
    final userAverages = <UserEngagementData>[];

    for (final slot in timeSlots) {
      // Calculate total average for this time slot
      // Include data points: start <= createdAt < end
      final slotData = rawData
          .where((d) =>
              (d.createdAt.isAtSameMomentAs(slot.start) ||
                  d.createdAt.isAfter(slot.start)) &&
              d.createdAt.isBefore(slot.end))
          .toList();

      if (slotData.isNotEmpty) {
        final avgValue = slotData.map((d) => d.value).reduce((a, b) => a + b) /
            slotData.length;
        totalAverages.add(EngagementDataPoint(
          timeSlotStart: slot.start.toIso8601String(),
          avgValue: avgValue,
        ));

        print(
            '  📈 Slot ${slot.start.toString().substring(11, 19)} - ${slot.end.toString().substring(11, 19)}: ${slotData.length} data points, avg: ${(avgValue * 100).toStringAsFixed(1)}%');
      }

      // Calculate user averages for this time slot
      for (final userId in userData.keys) {
        final userSlotData = userData[userId]!
            .where((d) =>
                (d.createdAt.isAtSameMomentAs(slot.start) ||
                    d.createdAt.isAfter(slot.start)) &&
                d.createdAt.isBefore(slot.end))
            .toList();

        if (userSlotData.isNotEmpty) {
          final userAvgValue =
              userSlotData.map((d) => d.value).reduce((a, b) => a + b) /
                  userSlotData.length;

          // Find or create user data
          var userEngagement = userAverages.firstWhere(
            (u) => u.userId == userId,
            orElse: () => UserEngagementData(
              userId: userId,
              name: userData[userId]!.first.userName,
              data: [],
            ),
          );

          if (userAverages.contains(userEngagement)) {
            userAverages.remove(userEngagement);
          }

          userEngagement = UserEngagementData(
            userId: userId,
            name: userEngagement.name,
            data: [
              ...userEngagement.data,
              EngagementDataPoint(
                timeSlotStart: slot.start.toIso8601String(),
                avgValue: userAvgValue,
              ),
            ],
          );

          userAverages.add(userEngagement);
        }
      }
    }

    return EngagementTotalAverageDto(
      totalAttentionAverage: totalAverages,
      usersAverage: userAverages,
    );
  }

  static List<TimeSlot> _calculateTimeSlots(List<RawEngagementData> rawData) {
    if (rawData.isEmpty) return [];

    final firstTime =
        rawData.map((d) => d.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
    final lastTime =
        rawData.map((d) => d.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);

    // Always build 5 dynamic slots across the whole duration (min slot = 5s)
    final totalSeconds = lastTime.difference(firstTime).inSeconds.abs();
    if (totalSeconds <= 0) {
      return [
        TimeSlot(
            start: firstTime, end: firstTime.add(const Duration(seconds: 5)))
      ];
    }

    const desiredSlots = 5;
    final slotSeconds = (totalSeconds / desiredSlots).ceil();
    final effectiveSlotSeconds = slotSeconds < 5 ? 5 : slotSeconds;

    final slots = <TimeSlot>[];
    var currentTime = firstTime;

    for (int i = 0; i < desiredSlots; i++) {
      final slotStart = currentTime;
      // Last slot ends exactly at lastTime to avoid trailing gaps/overruns
      final slotEnd = i == desiredSlots - 1
          ? lastTime
          : currentTime.add(Duration(seconds: effectiveSlotSeconds));
      slots.add(TimeSlot(start: slotStart, end: slotEnd));
      currentTime = slotEnd;
    }

    final durationInMinutes = totalSeconds / 60;
    print(
        '📊 Meeting duration: ${durationInMinutes.toStringAsFixed(1)} min, Slots: ${slots.length}, Slot span: ~${effectiveSlotSeconds}s');

    return slots;
  }
}

class EngagementDataPoint {
  final String timeSlotStart;
  final double avgValue;

  EngagementDataPoint({
    required this.timeSlotStart,
    required this.avgValue,
  });

  factory EngagementDataPoint.fromJson(Map<String, dynamic> json) {
    return EngagementDataPoint(
      timeSlotStart: json['time_slot_start'] as String? ?? '',
      avgValue: double.tryParse(json['avg_value']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_slot_start': timeSlotStart,
      'avg_value': avgValue.toString(),
    };
  }
}

class UserEngagementData {
  final int userId;
  final String name;
  final List<EngagementDataPoint> data;

  UserEngagementData({
    required this.userId,
    required this.name,
    required this.data,
  });

  factory UserEngagementData.fromJson(Map<String, dynamic> json) {
    return UserEngagementData(
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) =>
                  EngagementDataPoint.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'data': data.map((d) => d.toJson()).toList(),
    };
  }
}

class RawEngagementData {
  final int id;
  final int meetingId;
  final int userId;
  final String userName;
  final int moduleId;
  final String moduleName;
  final double value;
  final DateTime createdAt;

  RawEngagementData({
    required this.id,
    required this.meetingId,
    required this.userId,
    required this.userName,
    required this.moduleId,
    required this.moduleName,
    required this.value,
    required this.createdAt,
  });

  factory RawEngagementData.fromJson(Map<String, dynamic> json) {
    return RawEngagementData(
      id: json['id'] as int? ?? 0,
      meetingId: json['meeting_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String? ?? '',
      moduleId: json['module_id'] as int? ?? 0,
      moduleName: json['module_name'] as String? ?? '',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

class TimeSlot {
  final DateTime start;
  final DateTime end;

  TimeSlot({required this.start, required this.end});
}
