// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_fs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserRolesImpl _$$UserRolesImplFromJson(Map<String, dynamic> json) =>
    _$UserRolesImpl(admin: json['admin'] as bool? ?? false);

Map<String, dynamic> _$$UserRolesImplToJson(_$UserRolesImpl instance) =>
    <String, dynamic>{'admin': instance.admin};

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
      articles: (json['articles'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{'articles': instance.articles, 'likes': instance.likes};

_$UserProfileFsImpl _$$UserProfileFsImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileFsImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      bio: json['bio'] as String? ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
      roles: json['roles'] == null
          ? const UserRoles()
          : UserRoles.fromJson(json['roles'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? const UserStats()
          : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserProfileFsImplToJson(_$UserProfileFsImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'bio': instance.bio,
      'city': instance.city,
      'state': instance.state,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastSeenAt': instance.lastSeenAt.toIso8601String(),
      'roles': instance.roles,
      'stats': instance.stats,
    };
