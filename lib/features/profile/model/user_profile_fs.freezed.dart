// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_fs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserRoles _$UserRolesFromJson(Map<String, dynamic> json) {
  return _UserRoles.fromJson(json);
}

/// @nodoc
mixin _$UserRoles {
  bool get admin => throw _privateConstructorUsedError;

  /// Serializes this UserRoles to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserRoles
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserRolesCopyWith<UserRoles> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserRolesCopyWith<$Res> {
  factory $UserRolesCopyWith(UserRoles value, $Res Function(UserRoles) then) =
      _$UserRolesCopyWithImpl<$Res, UserRoles>;
  @useResult
  $Res call({bool admin});
}

/// @nodoc
class _$UserRolesCopyWithImpl<$Res, $Val extends UserRoles>
    implements $UserRolesCopyWith<$Res> {
  _$UserRolesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserRoles
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? admin = null}) {
    return _then(
      _value.copyWith(
            admin: null == admin
                ? _value.admin
                : admin // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserRolesImplCopyWith<$Res>
    implements $UserRolesCopyWith<$Res> {
  factory _$$UserRolesImplCopyWith(
    _$UserRolesImpl value,
    $Res Function(_$UserRolesImpl) then,
  ) = __$$UserRolesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool admin});
}

/// @nodoc
class __$$UserRolesImplCopyWithImpl<$Res>
    extends _$UserRolesCopyWithImpl<$Res, _$UserRolesImpl>
    implements _$$UserRolesImplCopyWith<$Res> {
  __$$UserRolesImplCopyWithImpl(
    _$UserRolesImpl _value,
    $Res Function(_$UserRolesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserRoles
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? admin = null}) {
    return _then(
      _$UserRolesImpl(
        admin: null == admin
            ? _value.admin
            : admin // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserRolesImpl implements _UserRoles {
  const _$UserRolesImpl({this.admin = false});

  factory _$UserRolesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserRolesImplFromJson(json);

  @override
  @JsonKey()
  final bool admin;

  @override
  String toString() {
    return 'UserRoles(admin: $admin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserRolesImpl &&
            (identical(other.admin, admin) || other.admin == admin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, admin);

  /// Create a copy of UserRoles
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserRolesImplCopyWith<_$UserRolesImpl> get copyWith =>
      __$$UserRolesImplCopyWithImpl<_$UserRolesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserRolesImplToJson(this);
  }
}

abstract class _UserRoles implements UserRoles {
  const factory _UserRoles({final bool admin}) = _$UserRolesImpl;

  factory _UserRoles.fromJson(Map<String, dynamic> json) =
      _$UserRolesImpl.fromJson;

  @override
  bool get admin;

  /// Create a copy of UserRoles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserRolesImplCopyWith<_$UserRolesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserStats _$UserStatsFromJson(Map<String, dynamic> json) {
  return _UserStats.fromJson(json);
}

/// @nodoc
mixin _$UserStats {
  int get articles => throw _privateConstructorUsedError;
  int get likes => throw _privateConstructorUsedError;

  /// Serializes this UserStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStatsCopyWith<UserStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatsCopyWith<$Res> {
  factory $UserStatsCopyWith(UserStats value, $Res Function(UserStats) then) =
      _$UserStatsCopyWithImpl<$Res, UserStats>;
  @useResult
  $Res call({int articles, int likes});
}

/// @nodoc
class _$UserStatsCopyWithImpl<$Res, $Val extends UserStats>
    implements $UserStatsCopyWith<$Res> {
  _$UserStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? articles = null, Object? likes = null}) {
    return _then(
      _value.copyWith(
            articles: null == articles
                ? _value.articles
                : articles // ignore: cast_nullable_to_non_nullable
                      as int,
            likes: null == likes
                ? _value.likes
                : likes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserStatsImplCopyWith<$Res>
    implements $UserStatsCopyWith<$Res> {
  factory _$$UserStatsImplCopyWith(
    _$UserStatsImpl value,
    $Res Function(_$UserStatsImpl) then,
  ) = __$$UserStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int articles, int likes});
}

/// @nodoc
class __$$UserStatsImplCopyWithImpl<$Res>
    extends _$UserStatsCopyWithImpl<$Res, _$UserStatsImpl>
    implements _$$UserStatsImplCopyWith<$Res> {
  __$$UserStatsImplCopyWithImpl(
    _$UserStatsImpl _value,
    $Res Function(_$UserStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? articles = null, Object? likes = null}) {
    return _then(
      _$UserStatsImpl(
        articles: null == articles
            ? _value.articles
            : articles // ignore: cast_nullable_to_non_nullable
                  as int,
        likes: null == likes
            ? _value.likes
            : likes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStatsImpl implements _UserStats {
  const _$UserStatsImpl({this.articles = 0, this.likes = 0});

  factory _$UserStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsImplFromJson(json);

  @override
  @JsonKey()
  final int articles;
  @override
  @JsonKey()
  final int likes;

  @override
  String toString() {
    return 'UserStats(articles: $articles, likes: $likes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatsImpl &&
            (identical(other.articles, articles) ||
                other.articles == articles) &&
            (identical(other.likes, likes) || other.likes == likes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, articles, likes);

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatsImplCopyWith<_$UserStatsImpl> get copyWith =>
      __$$UserStatsImplCopyWithImpl<_$UserStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatsImplToJson(this);
  }
}

abstract class _UserStats implements UserStats {
  const factory _UserStats({final int articles, final int likes}) =
      _$UserStatsImpl;

  factory _UserStats.fromJson(Map<String, dynamic> json) =
      _$UserStatsImpl.fromJson;

  @override
  int get articles;
  @override
  int get likes;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStatsImplCopyWith<_$UserStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfileFs _$UserProfileFsFromJson(Map<String, dynamic> json) {
  return _UserProfileFs.fromJson(json);
}

/// @nodoc
mixin _$UserProfileFs {
  String get uid => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get photoURL => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastSeenAt => throw _privateConstructorUsedError;
  UserRoles get roles => throw _privateConstructorUsedError;
  UserStats get stats => throw _privateConstructorUsedError;

  /// Serializes this UserProfileFs to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileFs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileFsCopyWith<UserProfileFs> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileFsCopyWith<$Res> {
  factory $UserProfileFsCopyWith(
    UserProfileFs value,
    $Res Function(UserProfileFs) then,
  ) = _$UserProfileFsCopyWithImpl<$Res, UserProfileFs>;
  @useResult
  $Res call({
    String uid,
    String displayName,
    String? photoURL,
    String bio,
    String? city,
    String? state,
    DateTime createdAt,
    DateTime lastSeenAt,
    UserRoles roles,
    UserStats stats,
  });

  $UserRolesCopyWith<$Res> get roles;
  $UserStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$UserProfileFsCopyWithImpl<$Res, $Val extends UserProfileFs>
    implements $UserProfileFsCopyWith<$Res> {
  _$UserProfileFsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileFs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? photoURL = freezed,
    Object? bio = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? createdAt = null,
    Object? lastSeenAt = null,
    Object? roles = null,
    Object? stats = null,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            photoURL: freezed == photoURL
                ? _value.photoURL
                : photoURL // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: null == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            state: freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastSeenAt: null == lastSeenAt
                ? _value.lastSeenAt
                : lastSeenAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as UserRoles,
            stats: null == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as UserStats,
          )
          as $Val,
    );
  }

  /// Create a copy of UserProfileFs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserRolesCopyWith<$Res> get roles {
    return $UserRolesCopyWith<$Res>(_value.roles, (value) {
      return _then(_value.copyWith(roles: value) as $Val);
    });
  }

  /// Create a copy of UserProfileFs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserStatsCopyWith<$Res> get stats {
    return $UserStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileFsImplCopyWith<$Res>
    implements $UserProfileFsCopyWith<$Res> {
  factory _$$UserProfileFsImplCopyWith(
    _$UserProfileFsImpl value,
    $Res Function(_$UserProfileFsImpl) then,
  ) = __$$UserProfileFsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String displayName,
    String? photoURL,
    String bio,
    String? city,
    String? state,
    DateTime createdAt,
    DateTime lastSeenAt,
    UserRoles roles,
    UserStats stats,
  });

  @override
  $UserRolesCopyWith<$Res> get roles;
  @override
  $UserStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$UserProfileFsImplCopyWithImpl<$Res>
    extends _$UserProfileFsCopyWithImpl<$Res, _$UserProfileFsImpl>
    implements _$$UserProfileFsImplCopyWith<$Res> {
  __$$UserProfileFsImplCopyWithImpl(
    _$UserProfileFsImpl _value,
    $Res Function(_$UserProfileFsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfileFs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? photoURL = freezed,
    Object? bio = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? createdAt = null,
    Object? lastSeenAt = null,
    Object? roles = null,
    Object? stats = null,
  }) {
    return _then(
      _$UserProfileFsImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        photoURL: freezed == photoURL
            ? _value.photoURL
            : photoURL // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: null == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        state: freezed == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastSeenAt: null == lastSeenAt
            ? _value.lastSeenAt
            : lastSeenAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        roles: null == roles
            ? _value.roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as UserRoles,
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as UserStats,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileFsImpl implements _UserProfileFs {
  const _$UserProfileFsImpl({
    required this.uid,
    required this.displayName,
    this.photoURL,
    this.bio = '',
    this.city,
    this.state,
    required this.createdAt,
    required this.lastSeenAt,
    this.roles = const UserRoles(),
    this.stats = const UserStats(),
  });

  factory _$UserProfileFsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileFsImplFromJson(json);

  @override
  final String uid;
  @override
  final String displayName;
  @override
  final String? photoURL;
  @override
  @JsonKey()
  final String bio;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final DateTime createdAt;
  @override
  final DateTime lastSeenAt;
  @override
  @JsonKey()
  final UserRoles roles;
  @override
  @JsonKey()
  final UserStats stats;

  @override
  String toString() {
    return 'UserProfileFs(uid: $uid, displayName: $displayName, photoURL: $photoURL, bio: $bio, city: $city, state: $state, createdAt: $createdAt, lastSeenAt: $lastSeenAt, roles: $roles, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileFsImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoURL, photoURL) ||
                other.photoURL == photoURL) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastSeenAt, lastSeenAt) ||
                other.lastSeenAt == lastSeenAt) &&
            (identical(other.roles, roles) || other.roles == roles) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    displayName,
    photoURL,
    bio,
    city,
    state,
    createdAt,
    lastSeenAt,
    roles,
    stats,
  );

  /// Create a copy of UserProfileFs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileFsImplCopyWith<_$UserProfileFsImpl> get copyWith =>
      __$$UserProfileFsImplCopyWithImpl<_$UserProfileFsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileFsImplToJson(this);
  }
}

abstract class _UserProfileFs implements UserProfileFs {
  const factory _UserProfileFs({
    required final String uid,
    required final String displayName,
    final String? photoURL,
    final String bio,
    final String? city,
    final String? state,
    required final DateTime createdAt,
    required final DateTime lastSeenAt,
    final UserRoles roles,
    final UserStats stats,
  }) = _$UserProfileFsImpl;

  factory _UserProfileFs.fromJson(Map<String, dynamic> json) =
      _$UserProfileFsImpl.fromJson;

  @override
  String get uid;
  @override
  String get displayName;
  @override
  String? get photoURL;
  @override
  String get bio;
  @override
  String? get city;
  @override
  String? get state;
  @override
  DateTime get createdAt;
  @override
  DateTime get lastSeenAt;
  @override
  UserRoles get roles;
  @override
  UserStats get stats;

  /// Create a copy of UserProfileFs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileFsImplCopyWith<_$UserProfileFsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
