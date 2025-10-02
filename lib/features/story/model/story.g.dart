// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryImpl _$$StoryImplFromJson(Map<String, dynamic> json) => _$StoryImpl(
  id: json['id'] as String,
  metroId: json['metroId'] as String,
  type: $enumDecode(_$StoryTypeEnumMap, json['type']),
  title: json['title'] as String,
  subhead: json['subhead'] as String?,
  body: json['body'] as String?,
  imageUrl: json['imageUrl'] as String?,
  sourceLinks:
      (json['sourceLinks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  status: $enumDecode(_$StoryStatusEnumMap, json['status']),
);

Map<String, dynamic> _$$StoryImplToJson(_$StoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'metroId': instance.metroId,
      'type': _$StoryTypeEnumMap[instance.type]!,
      'title': instance.title,
      'subhead': instance.subhead,
      'body': instance.body,
      'imageUrl': instance.imageUrl,
      'sourceLinks': instance.sourceLinks,
      'likesCount': instance.likesCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'status': _$StoryStatusEnumMap[instance.status]!,
    };

const _$StoryTypeEnumMap = {
  StoryType.original: 'original',
  StoryType.summaryLink: 'summary_link',
  StoryType.user: 'user',
};

const _$StoryStatusEnumMap = {
  StoryStatus.queued: 'queued',
  StoryStatus.approved: 'approved',
  StoryStatus.published: 'published',
  StoryStatus.rejected: 'rejected',
};
