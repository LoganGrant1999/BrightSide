// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Story _$StoryFromJson(Map<String, dynamic> json) {
  return _Story.fromJson(json);
}

/// @nodoc
mixin _$Story {
  String get id => throw _privateConstructorUsedError;
  String get metroId => throw _privateConstructorUsedError;
  StoryType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get subhead => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get sourceName => throw _privateConstructorUsedError;
  String? get sourceUrl => throw _privateConstructorUsedError;
  List<String> get sourceLinks => throw _privateConstructorUsedError;
  int get likesCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  StoryStatus get status => throw _privateConstructorUsedError;

  /// Serializes this Story to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryCopyWith<Story> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryCopyWith<$Res> {
  factory $StoryCopyWith(Story value, $Res Function(Story) then) =
      _$StoryCopyWithImpl<$Res, Story>;
  @useResult
  $Res call({
    String id,
    String metroId,
    StoryType type,
    String title,
    String? subhead,
    String? body,
    String? imageUrl,
    String? sourceName,
    String? sourceUrl,
    List<String> sourceLinks,
    int likesCount,
    DateTime createdAt,
    DateTime? publishedAt,
    StoryStatus status,
  });
}

/// @nodoc
class _$StoryCopyWithImpl<$Res, $Val extends Story>
    implements $StoryCopyWith<$Res> {
  _$StoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? metroId = null,
    Object? type = null,
    Object? title = null,
    Object? subhead = freezed,
    Object? body = freezed,
    Object? imageUrl = freezed,
    Object? sourceName = freezed,
    Object? sourceUrl = freezed,
    Object? sourceLinks = null,
    Object? likesCount = null,
    Object? createdAt = null,
    Object? publishedAt = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            metroId: null == metroId
                ? _value.metroId
                : metroId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as StoryType,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            subhead: freezed == subhead
                ? _value.subhead
                : subhead // ignore: cast_nullable_to_non_nullable
                      as String?,
            body: freezed == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceName: freezed == sourceName
                ? _value.sourceName
                : sourceName // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceUrl: freezed == sourceUrl
                ? _value.sourceUrl
                : sourceUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceLinks: null == sourceLinks
                ? _value.sourceLinks
                : sourceLinks // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            likesCount: null == likesCount
                ? _value.likesCount
                : likesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            publishedAt: freezed == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as StoryStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoryImplCopyWith<$Res> implements $StoryCopyWith<$Res> {
  factory _$$StoryImplCopyWith(
    _$StoryImpl value,
    $Res Function(_$StoryImpl) then,
  ) = __$$StoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String metroId,
    StoryType type,
    String title,
    String? subhead,
    String? body,
    String? imageUrl,
    String? sourceName,
    String? sourceUrl,
    List<String> sourceLinks,
    int likesCount,
    DateTime createdAt,
    DateTime? publishedAt,
    StoryStatus status,
  });
}

/// @nodoc
class __$$StoryImplCopyWithImpl<$Res>
    extends _$StoryCopyWithImpl<$Res, _$StoryImpl>
    implements _$$StoryImplCopyWith<$Res> {
  __$$StoryImplCopyWithImpl(
    _$StoryImpl _value,
    $Res Function(_$StoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? metroId = null,
    Object? type = null,
    Object? title = null,
    Object? subhead = freezed,
    Object? body = freezed,
    Object? imageUrl = freezed,
    Object? sourceName = freezed,
    Object? sourceUrl = freezed,
    Object? sourceLinks = null,
    Object? likesCount = null,
    Object? createdAt = null,
    Object? publishedAt = freezed,
    Object? status = null,
  }) {
    return _then(
      _$StoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        metroId: null == metroId
            ? _value.metroId
            : metroId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as StoryType,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        subhead: freezed == subhead
            ? _value.subhead
            : subhead // ignore: cast_nullable_to_non_nullable
                  as String?,
        body: freezed == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceName: freezed == sourceName
            ? _value.sourceName
            : sourceName // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceUrl: freezed == sourceUrl
            ? _value.sourceUrl
            : sourceUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceLinks: null == sourceLinks
            ? _value._sourceLinks
            : sourceLinks // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        likesCount: null == likesCount
            ? _value.likesCount
            : likesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        publishedAt: freezed == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as StoryStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryImpl implements _Story {
  const _$StoryImpl({
    required this.id,
    required this.metroId,
    required this.type,
    required this.title,
    this.subhead,
    this.body,
    this.imageUrl,
    this.sourceName,
    this.sourceUrl,
    final List<String> sourceLinks = const [],
    this.likesCount = 0,
    required this.createdAt,
    this.publishedAt,
    required this.status,
  }) : _sourceLinks = sourceLinks;

  factory _$StoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryImplFromJson(json);

  @override
  final String id;
  @override
  final String metroId;
  @override
  final StoryType type;
  @override
  final String title;
  @override
  final String? subhead;
  @override
  final String? body;
  @override
  final String? imageUrl;
  @override
  final String? sourceName;
  @override
  final String? sourceUrl;
  final List<String> _sourceLinks;
  @override
  @JsonKey()
  List<String> get sourceLinks {
    if (_sourceLinks is EqualUnmodifiableListView) return _sourceLinks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceLinks);
  }

  @override
  @JsonKey()
  final int likesCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime? publishedAt;
  @override
  final StoryStatus status;

  @override
  String toString() {
    return 'Story(id: $id, metroId: $metroId, type: $type, title: $title, subhead: $subhead, body: $body, imageUrl: $imageUrl, sourceName: $sourceName, sourceUrl: $sourceUrl, sourceLinks: $sourceLinks, likesCount: $likesCount, createdAt: $createdAt, publishedAt: $publishedAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.metroId, metroId) || other.metroId == metroId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subhead, subhead) || other.subhead == subhead) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.sourceName, sourceName) ||
                other.sourceName == sourceName) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            const DeepCollectionEquality().equals(
              other._sourceLinks,
              _sourceLinks,
            ) &&
            (identical(other.likesCount, likesCount) ||
                other.likesCount == likesCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    metroId,
    type,
    title,
    subhead,
    body,
    imageUrl,
    sourceName,
    sourceUrl,
    const DeepCollectionEquality().hash(_sourceLinks),
    likesCount,
    createdAt,
    publishedAt,
    status,
  );

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryImplCopyWith<_$StoryImpl> get copyWith =>
      __$$StoryImplCopyWithImpl<_$StoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryImplToJson(this);
  }
}

abstract class _Story implements Story {
  const factory _Story({
    required final String id,
    required final String metroId,
    required final StoryType type,
    required final String title,
    final String? subhead,
    final String? body,
    final String? imageUrl,
    final String? sourceName,
    final String? sourceUrl,
    final List<String> sourceLinks,
    final int likesCount,
    required final DateTime createdAt,
    final DateTime? publishedAt,
    required final StoryStatus status,
  }) = _$StoryImpl;

  factory _Story.fromJson(Map<String, dynamic> json) = _$StoryImpl.fromJson;

  @override
  String get id;
  @override
  String get metroId;
  @override
  StoryType get type;
  @override
  String get title;
  @override
  String? get subhead;
  @override
  String? get body;
  @override
  String? get imageUrl;
  @override
  String? get sourceName;
  @override
  String? get sourceUrl;
  @override
  List<String> get sourceLinks;
  @override
  int get likesCount;
  @override
  DateTime get createdAt;
  @override
  DateTime? get publishedAt;
  @override
  StoryStatus get status;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryImplCopyWith<_$StoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
