import 'package:freezed_annotation/freezed_annotation.dart';

part 'submission_fs.freezed.dart';
part 'submission_fs.g.dart';

enum SubmissionStatus {
  pending,
  approved,
  rejected,
}

@freezed
class SubmissionFs with _$SubmissionFs {
  const factory SubmissionFs({
    required String id,
    required String submittedByUid,
    required String title,
    required String desc,
    required String city,
    required String state,
    required DateTime when,
    String? photoUrl,
    @Default(SubmissionStatus.pending) SubmissionStatus status,
    required DateTime createdAt,
  }) = _SubmissionFs;

  factory SubmissionFs.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFsFromJson(json);
}
