// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submission_fs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubmissionFs _$SubmissionFsFromJson(Map<String, dynamic> json) {
  return _SubmissionFs.fromJson(json);
}

/// @nodoc
mixin _$SubmissionFs {
  String get id => throw _privateConstructorUsedError;
  String get submittedByUid => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get desc => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  DateTime get when => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  SubmissionStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SubmissionFs to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmissionFs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmissionFsCopyWith<SubmissionFs> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmissionFsCopyWith<$Res> {
  factory $SubmissionFsCopyWith(
    SubmissionFs value,
    $Res Function(SubmissionFs) then,
  ) = _$SubmissionFsCopyWithImpl<$Res, SubmissionFs>;
  @useResult
  $Res call({
    String id,
    String submittedByUid,
    String title,
    String desc,
    String city,
    String state,
    DateTime when,
    String? photoUrl,
    SubmissionStatus status,
    DateTime createdAt,
  });
}

/// @nodoc
class _$SubmissionFsCopyWithImpl<$Res, $Val extends SubmissionFs>
    implements $SubmissionFsCopyWith<$Res> {
  _$SubmissionFsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmissionFs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submittedByUid = null,
    Object? title = null,
    Object? desc = null,
    Object? city = null,
    Object? state = null,
    Object? when = null,
    Object? photoUrl = freezed,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            submittedByUid: null == submittedByUid
                ? _value.submittedByUid
                : submittedByUid // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            desc: null == desc
                ? _value.desc
                : desc // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String,
            when: null == when
                ? _value.when
                : when // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SubmissionStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmissionFsImplCopyWith<$Res>
    implements $SubmissionFsCopyWith<$Res> {
  factory _$$SubmissionFsImplCopyWith(
    _$SubmissionFsImpl value,
    $Res Function(_$SubmissionFsImpl) then,
  ) = __$$SubmissionFsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String submittedByUid,
    String title,
    String desc,
    String city,
    String state,
    DateTime when,
    String? photoUrl,
    SubmissionStatus status,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$SubmissionFsImplCopyWithImpl<$Res>
    extends _$SubmissionFsCopyWithImpl<$Res, _$SubmissionFsImpl>
    implements _$$SubmissionFsImplCopyWith<$Res> {
  __$$SubmissionFsImplCopyWithImpl(
    _$SubmissionFsImpl _value,
    $Res Function(_$SubmissionFsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubmissionFs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submittedByUid = null,
    Object? title = null,
    Object? desc = null,
    Object? city = null,
    Object? state = null,
    Object? when = null,
    Object? photoUrl = freezed,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SubmissionFsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        submittedByUid: null == submittedByUid
            ? _value.submittedByUid
            : submittedByUid // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        desc: null == desc
            ? _value.desc
            : desc // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        when: null == when
            ? _value.when
            : when // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SubmissionStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmissionFsImpl implements _SubmissionFs {
  const _$SubmissionFsImpl({
    required this.id,
    required this.submittedByUid,
    required this.title,
    required this.desc,
    required this.city,
    required this.state,
    required this.when,
    this.photoUrl,
    this.status = SubmissionStatus.pending,
    required this.createdAt,
  });

  factory _$SubmissionFsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmissionFsImplFromJson(json);

  @override
  final String id;
  @override
  final String submittedByUid;
  @override
  final String title;
  @override
  final String desc;
  @override
  final String city;
  @override
  final String state;
  @override
  final DateTime when;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final SubmissionStatus status;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SubmissionFs(id: $id, submittedByUid: $submittedByUid, title: $title, desc: $desc, city: $city, state: $state, when: $when, photoUrl: $photoUrl, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmissionFsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.submittedByUid, submittedByUid) ||
                other.submittedByUid == submittedByUid) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.when, when) || other.when == when) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    submittedByUid,
    title,
    desc,
    city,
    state,
    when,
    photoUrl,
    status,
    createdAt,
  );

  /// Create a copy of SubmissionFs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmissionFsImplCopyWith<_$SubmissionFsImpl> get copyWith =>
      __$$SubmissionFsImplCopyWithImpl<_$SubmissionFsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmissionFsImplToJson(this);
  }
}

abstract class _SubmissionFs implements SubmissionFs {
  const factory _SubmissionFs({
    required final String id,
    required final String submittedByUid,
    required final String title,
    required final String desc,
    required final String city,
    required final String state,
    required final DateTime when,
    final String? photoUrl,
    final SubmissionStatus status,
    required final DateTime createdAt,
  }) = _$SubmissionFsImpl;

  factory _SubmissionFs.fromJson(Map<String, dynamic> json) =
      _$SubmissionFsImpl.fromJson;

  @override
  String get id;
  @override
  String get submittedByUid;
  @override
  String get title;
  @override
  String get desc;
  @override
  String get city;
  @override
  String get state;
  @override
  DateTime get when;
  @override
  String? get photoUrl;
  @override
  SubmissionStatus get status;
  @override
  DateTime get createdAt;

  /// Create a copy of SubmissionFs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmissionFsImplCopyWith<_$SubmissionFsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
