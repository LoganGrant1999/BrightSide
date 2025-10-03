// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_fs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubmissionFsImpl _$$SubmissionFsImplFromJson(Map<String, dynamic> json) =>
    _$SubmissionFsImpl(
      id: json['id'] as String,
      submittedByUid: json['submittedByUid'] as String,
      title: json['title'] as String,
      desc: json['desc'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      when: DateTime.parse(json['when'] as String),
      photoUrl: json['photoUrl'] as String?,
      status:
          $enumDecodeNullable(_$SubmissionStatusEnumMap, json['status']) ??
          SubmissionStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SubmissionFsImplToJson(_$SubmissionFsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submittedByUid': instance.submittedByUid,
      'title': instance.title,
      'desc': instance.desc,
      'city': instance.city,
      'state': instance.state,
      'when': instance.when.toIso8601String(),
      'photoUrl': instance.photoUrl,
      'status': _$SubmissionStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$SubmissionStatusEnumMap = {
  SubmissionStatus.pending: 'pending',
  SubmissionStatus.approved: 'approved',
  SubmissionStatus.rejected: 'rejected',
};
