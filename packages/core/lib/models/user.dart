import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole { buyer, seller, courier, admin }

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String phone,
    required UserRole role,
    String? avatarUrl,
    String? email,
    @Default(false) bool isVerified,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
