import 'package:freezed_annotation/freezed_annotation.dart';

part 'story.freezed.dart';
part 'story.g.dart';

enum StoryType {
  @JsonValue('original')
  original,
  @JsonValue('summary_link')
  summaryLink,
  @JsonValue('user')
  user,
}

enum StoryStatus {
  @JsonValue('queued')
  queued,
  @JsonValue('approved')
  approved,
  @JsonValue('published')
  published,
  @JsonValue('rejected')
  rejected,
}

@freezed
class Story with _$Story {
  const factory Story({
    required String id,
    required String metroId,
    required StoryType type,
    required String title,
    String? subhead,
    String? body,
    String? imageUrl,
    @Default([]) List<String> sourceLinks,
    @Default(0) int likesCount,
    required DateTime createdAt,
    DateTime? publishedAt,
    required StoryStatus status,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}
