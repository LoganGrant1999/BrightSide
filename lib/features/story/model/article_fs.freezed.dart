// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_fs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ArticleFs _$ArticleFsFromJson(Map<String, dynamic> json) {
  return _ArticleFs.fromJson(json);
}

/// @nodoc
mixin _$ArticleFs {
  String get id => throw _privateConstructorUsedError;
  String get metroId => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get snippet => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String get authorUid => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;
  String? get authorPhotoURL => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  bool get featured => throw _privateConstructorUsedError;
  DateTime? get featuredAt => throw _privateConstructorUsedError;
  DateTime get publishedAt => throw _privateConstructorUsedError;
  ArticleStatus get status => throw _privateConstructorUsedError;

  /// Serializes this ArticleFs to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArticleFs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleFsCopyWith<ArticleFs> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleFsCopyWith<$Res> {
  factory $ArticleFsCopyWith(ArticleFs value, $Res Function(ArticleFs) then) =
      _$ArticleFsCopyWithImpl<$Res, ArticleFs>;
  @useResult
  $Res call({
    String id,
    String metroId,
    String state,
    String city,
    String title,
    String snippet,
    String body,
    String? imageUrl,
    String authorUid,
    String authorName,
    String? authorPhotoURL,
    int likeCount,
    bool featured,
    DateTime? featuredAt,
    DateTime publishedAt,
    ArticleStatus status,
  });
}

/// @nodoc
class _$ArticleFsCopyWithImpl<$Res, $Val extends ArticleFs>
    implements $ArticleFsCopyWith<$Res> {
  _$ArticleFsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleFs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? metroId = null,
    Object? state = null,
    Object? city = null,
    Object? title = null,
    Object? snippet = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? authorUid = null,
    Object? authorName = null,
    Object? authorPhotoURL = freezed,
    Object? likeCount = null,
    Object? featured = null,
    Object? featuredAt = freezed,
    Object? publishedAt = null,
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
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            snippet: null == snippet
                ? _value.snippet
                : snippet // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorUid: null == authorUid
                ? _value.authorUid
                : authorUid // ignore: cast_nullable_to_non_nullable
                      as String,
            authorName: null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String,
            authorPhotoURL: freezed == authorPhotoURL
                ? _value.authorPhotoURL
                : authorPhotoURL // ignore: cast_nullable_to_non_nullable
                      as String?,
            likeCount: null == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            featured: null == featured
                ? _value.featured
                : featured // ignore: cast_nullable_to_non_nullable
                      as bool,
            featuredAt: freezed == featuredAt
                ? _value.featuredAt
                : featuredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            publishedAt: null == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ArticleStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArticleFsImplCopyWith<$Res>
    implements $ArticleFsCopyWith<$Res> {
  factory _$$ArticleFsImplCopyWith(
    _$ArticleFsImpl value,
    $Res Function(_$ArticleFsImpl) then,
  ) = __$$ArticleFsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String metroId,
    String state,
    String city,
    String title,
    String snippet,
    String body,
    String? imageUrl,
    String authorUid,
    String authorName,
    String? authorPhotoURL,
    int likeCount,
    bool featured,
    DateTime? featuredAt,
    DateTime publishedAt,
    ArticleStatus status,
  });
}

/// @nodoc
class __$$ArticleFsImplCopyWithImpl<$Res>
    extends _$ArticleFsCopyWithImpl<$Res, _$ArticleFsImpl>
    implements _$$ArticleFsImplCopyWith<$Res> {
  __$$ArticleFsImplCopyWithImpl(
    _$ArticleFsImpl _value,
    $Res Function(_$ArticleFsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArticleFs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? metroId = null,
    Object? state = null,
    Object? city = null,
    Object? title = null,
    Object? snippet = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? authorUid = null,
    Object? authorName = null,
    Object? authorPhotoURL = freezed,
    Object? likeCount = null,
    Object? featured = null,
    Object? featuredAt = freezed,
    Object? publishedAt = null,
    Object? status = null,
  }) {
    return _then(
      _$ArticleFsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        metroId: null == metroId
            ? _value.metroId
            : metroId // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        snippet: null == snippet
            ? _value.snippet
            : snippet // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorUid: null == authorUid
            ? _value.authorUid
            : authorUid // ignore: cast_nullable_to_non_nullable
                  as String,
        authorName: null == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String,
        authorPhotoURL: freezed == authorPhotoURL
            ? _value.authorPhotoURL
            : authorPhotoURL // ignore: cast_nullable_to_non_nullable
                  as String?,
        likeCount: null == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        featured: null == featured
            ? _value.featured
            : featured // ignore: cast_nullable_to_non_nullable
                  as bool,
        featuredAt: freezed == featuredAt
            ? _value.featuredAt
            : featuredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        publishedAt: null == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ArticleStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleFsImpl implements _ArticleFs {
  const _$ArticleFsImpl({
    required this.id,
    required this.metroId,
    required this.state,
    required this.city,
    required this.title,
    required this.snippet,
    required this.body,
    this.imageUrl,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoURL,
    this.likeCount = 0,
    this.featured = false,
    this.featuredAt,
    required this.publishedAt,
    this.status = ArticleStatus.draft,
  });

  factory _$ArticleFsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleFsImplFromJson(json);

  @override
  final String id;
  @override
  final String metroId;
  @override
  final String state;
  @override
  final String city;
  @override
  final String title;
  @override
  final String snippet;
  @override
  final String body;
  @override
  final String? imageUrl;
  @override
  final String authorUid;
  @override
  final String authorName;
  @override
  final String? authorPhotoURL;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final bool featured;
  @override
  final DateTime? featuredAt;
  @override
  final DateTime publishedAt;
  @override
  @JsonKey()
  final ArticleStatus status;

  @override
  String toString() {
    return 'ArticleFs(id: $id, metroId: $metroId, state: $state, city: $city, title: $title, snippet: $snippet, body: $body, imageUrl: $imageUrl, authorUid: $authorUid, authorName: $authorName, authorPhotoURL: $authorPhotoURL, likeCount: $likeCount, featured: $featured, featuredAt: $featuredAt, publishedAt: $publishedAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleFsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.metroId, metroId) || other.metroId == metroId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.snippet, snippet) || other.snippet == snippet) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.authorUid, authorUid) ||
                other.authorUid == authorUid) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorPhotoURL, authorPhotoURL) ||
                other.authorPhotoURL == authorPhotoURL) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.featured, featured) ||
                other.featured == featured) &&
            (identical(other.featuredAt, featuredAt) ||
                other.featuredAt == featuredAt) &&
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
    state,
    city,
    title,
    snippet,
    body,
    imageUrl,
    authorUid,
    authorName,
    authorPhotoURL,
    likeCount,
    featured,
    featuredAt,
    publishedAt,
    status,
  );

  /// Create a copy of ArticleFs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleFsImplCopyWith<_$ArticleFsImpl> get copyWith =>
      __$$ArticleFsImplCopyWithImpl<_$ArticleFsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleFsImplToJson(this);
  }
}

abstract class _ArticleFs implements ArticleFs {
  const factory _ArticleFs({
    required final String id,
    required final String metroId,
    required final String state,
    required final String city,
    required final String title,
    required final String snippet,
    required final String body,
    final String? imageUrl,
    required final String authorUid,
    required final String authorName,
    final String? authorPhotoURL,
    final int likeCount,
    final bool featured,
    final DateTime? featuredAt,
    required final DateTime publishedAt,
    final ArticleStatus status,
  }) = _$ArticleFsImpl;

  factory _ArticleFs.fromJson(Map<String, dynamic> json) =
      _$ArticleFsImpl.fromJson;

  @override
  String get id;
  @override
  String get metroId;
  @override
  String get state;
  @override
  String get city;
  @override
  String get title;
  @override
  String get snippet;
  @override
  String get body;
  @override
  String? get imageUrl;
  @override
  String get authorUid;
  @override
  String get authorName;
  @override
  String? get authorPhotoURL;
  @override
  int get likeCount;
  @override
  bool get featured;
  @override
  DateTime? get featuredAt;
  @override
  DateTime get publishedAt;
  @override
  ArticleStatus get status;

  /// Create a copy of ArticleFs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleFsImplCopyWith<_$ArticleFsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
