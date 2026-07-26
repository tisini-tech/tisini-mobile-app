import 'package:tisini/features/survey/domain/entities/survey_response_item.dart';

class SurveyResponseItemModel extends SurveyResponseItem {
  const SurveyResponseItemModel({
    required super.questionId,
    required super.value,
  });

  Map<String, dynamic> toJson() {
    Object? serialized;
    if (value is List) {
      serialized = (value as List).toList();
    } else if (value is Map) {
      serialized = Map<String, String>.from(value as Map);
    } else {
      serialized = value as String?;
    }
    return {
      'questionId': questionId,
      'value': serialized,
    };
  }

  factory SurveyResponseItemModel.fromJson(Map<String, dynamic> json) {
    final v = json['value'];
    if (v is List) {
      return SurveyResponseItemModel(
        questionId: json['questionId'] as int,
        value: List<String>.from(v),
      );
    }
    if (v is Map) {
      return SurveyResponseItemModel(
        questionId: json['questionId'] as int,
        value: Map<String, String>.from(v),
      );
    }
    return SurveyResponseItemModel(
      questionId: json['questionId'] as int,
      value: (v as String?) ?? '',
    );
  }

  factory SurveyResponseItemModel.fromEntity(SurveyResponseItem entity) {
    return SurveyResponseItemModel(
      questionId: entity.questionId,
      value: entity.value,
    );
  }
}
