import 'package:cinteraction_vc/core/io/network/models/data_channel_command.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class AppState extends Equatable {
  final UserStatus userStatus;
  final User? user;
  final bool isDarkMode;

  const AppState({
    required this.userStatus,
    required this.user,
    required this.isDarkMode,
  });

  const AppState.initial({
    UserStatus userStatus = UserStatus.offline,
    User? user,
    bool isDarkMode = false,
  }) : this(
          userStatus: userStatus,
          user: user,
          isDarkMode: isDarkMode,
        );

  AppState copyWith({
    UserStatus? userStatus,
    User? user,
    bool? isDarkMode,
  }) {

    print(isDarkMode);
    return AppState(
      userStatus: userStatus ?? this.userStatus,
      user: user ?? this.user,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [
        userStatus,
        user,
        isDarkMode
      ];
}
