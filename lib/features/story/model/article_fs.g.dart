// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_fs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleFsImpl _$$ArticleFsImplFromJson(Map<String, dynamic> json) =>
    _$ArticleFsImpl(
      id: json['id'] as String,
      metroId: json['metroId'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      title: json['title'] as String,
      snippet: json['snippet'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      authorUid: json['authorUid'] as String,
      authorName: json['authorName'] as String,
      authorPhotoURL: json['authorPhotoURL'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      featured: json['featured'] as bool? ?? false,
      featuredAt: json['featuredAt'] == null
          ? null
          : DateTime.parse(json['featuredAt'] as String),
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      status:
          $enumDecodeNullable(_$ArticleStatusEnumMap, json['status']) ??
          ArticleStatus.draft,
    );

Map<String, dynamic> _$$ArticleFsImplToJson(_$ArticleFsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'metroId': instance.metroId,
      'state': instance.state,
      'city': instance.city,
      'title': instance.title,
      'snippet': instance.snippet,
      'body': instance.body,
      'imageUrl': instance.imageUrl,
      'authorUid': instance.authorUid,
      'authorName': instance.authorName,
      'authorPhotoURL': instance.authorPhotoURL,
      'likeCount': instance.likeCount,
      'featured': instance.featured,
      'featuredAt': instance.featuredAt?.toIso8601String(),
      'publishedAt': instance.publishedAt.toIso8601String(),
      'status': _$ArticleStatusEnumMap[instance.status]!,
    };

const _$ArticleStatusEnumMap = {
  ArticleStatus.published: 'published',
  ArticleStatus.draft: 'draft',
};
