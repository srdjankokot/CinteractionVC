import 'package:cinteraction_vc/core/io/network/models/data_channel_command.dart';
import 'package:equatable/equatable.dart';

class AppState extends Equatable {
  final UserStatus userStatus;

  const AppState({
    required this.userStatus,
  });

  const AppState.initial({
    UserStatus userStatus = UserStatus.offline,
  }) : this(
          userStatus: userStatus,
        );

  AppState copyWith({
    UserStatus? userStatus,
  }) {
    return AppState(userStatus: userStatus ?? this.userStatus);
  }

  @override
  List<Object?> get props => [
        userStatus,
      ];
}
