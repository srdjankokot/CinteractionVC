import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto extends User {
  UserDto(
      {required super.id,
      required super.name,
      required super.email,
      required super.imageUrl,
      required super.createdAt});

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
