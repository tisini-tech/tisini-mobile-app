import 'package:tisini/features/survey/domain/entities/pending_survey_submission.dart';
import 'package:tisini/features/survey/data/models/survey_response_item_model.dart';

class PendingSurveySubmissionModel extends PendingSurveySubmission {
  const PendingSurveySubmissionModel({
    required super.id,
    required super.responses,
    required super.createdAt,
    super.synced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'responses': (responses as List<SurveyResponseItemModel>)
          .map((r) => r.toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'synced': synced,
    };
  }

  factory PendingSurveySubmissionModel.fromJson(Map<String, dynamic> json) {
    final list = json['responses'] as List<dynamic>? ?? [];
    return PendingSurveySubmissionModel(
      id: json['id'] as String,
      responses: list
          .map((e) => SurveyResponseItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      synced: json['synced'] as bool? ?? false,
    );
  }

  factory PendingSurveySubmissionModel.fromEntity(
    PendingSurveySubmission entity,
  ) {
    return PendingSurveySubmissionModel(
      id: entity.id,
      responses: entity.responses
          .map((e) => SurveyResponseItemModel.fromEntity(e))
          .toList(),
      createdAt: entity.createdAt,
      synced: entity.synced,
    );
  }
}
