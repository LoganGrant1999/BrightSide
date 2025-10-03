import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_fs.freezed.dart';
part 'article_fs.g.dart';

enum ArticleStatus {
  published,
  draft,
}

@freezed
class ArticleFs with _$ArticleFs {
  const factory ArticleFs({
    required String id,
    required String metroId,
    required String state,
    required String city,
    required String title,
    required String snippet,
    required String body,
    String? imageUrl,
    required String authorUid,
    required String authorName,
    String? authorPhotoURL,
    @Default(0) int likeCount,
    @Default(false) bool featured,
    DateTime? featuredAt,
    required DateTime publishedAt,
    @Default(ArticleStatus.draft) ArticleStatus status,
  }) = _ArticleFs;

  factory ArticleFs.fromJson(Map<String, dynamic> json) =>
      _$ArticleFsFromJson(json);
}
