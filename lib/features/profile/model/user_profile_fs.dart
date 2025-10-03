import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_fs.freezed.dart';
part 'user_profile_fs.g.dart';

@freezed
class UserRoles with _$UserRoles {
  const factory UserRoles({
    @Default(false) bool admin,
  }) = _UserRoles;

  factory UserRoles.fromJson(Map<String, dynamic> json) =>
      _$UserRolesFromJson(json);
}

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int articles,
    @Default(0) int likes,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}

@freezed
class UserProfileFs with _$UserProfileFs {
  const factory UserProfileFs({
    required String uid,
    required String displayName,
    String? photoURL,
    @Default('') String bio,
    String? city,
    String? state,
    required DateTime createdAt,
    required DateTime lastSeenAt,
    @Default(UserRoles()) UserRoles roles,
    @Default(UserStats()) UserStats stats,
  }) = _UserProfileFs;

  factory UserProfileFs.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFsFromJson(json);
}
