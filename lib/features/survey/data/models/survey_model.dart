import 'package:tisini/features/survey/data/models/engagement_model.dart';
import 'package:tisini/features/survey/domain/entities/engagement.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';

class SurveyModel extends Survey {
  SurveyModel({
    required super.id,
    required super.title,
    required super.dateCreated,
    required super.type,
    required super.noEngagement,
    required super.dateUpdated,
    required super.status,
    required super.engagements,
  });

  SurveyModel copyWith({
    String? id,
    String? title,
    DateTime? dateCreated,
    String? type,
    String? noEngagement,
    DateTime? dateUpdated,
    String? status,
    List<Engagement>? engagements,
  }) => SurveyModel(
    id: id ?? this.id,
    title: title ?? this.title,
    dateCreated: dateCreated ?? this.dateCreated,
    type: type ?? this.type,
    noEngagement: noEngagement ?? this.noEngagement,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    status: status ?? this.status,
    engagements: engagements ?? this.engagements,
  );

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    final engagementsRaw = json['engagements'];
    final engagements = engagementsRaw is List
        ? (engagementsRaw)
            .map((e) => EngagementModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList()
        : <Engagement>[];

    return SurveyModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      dateCreated: _parseDateTime(json['date_created']),
      type: (json['type'] ?? '').toString(),
      noEngagement: (json['no_engagement'] ?? '0').toString(),
      dateUpdated: _parseDateTime(json['date_updated']),
      status: (json['status'] ?? '0').toString(),
      engagements: engagements,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  factory SurveyModel.fromEntity(Survey entity) {
    return SurveyModel(
      id: entity.id,
      title: entity.title,
      dateCreated: entity.dateCreated,
      type: entity.type,
      noEngagement: entity.noEngagement,
      dateUpdated: entity.dateUpdated,
      status: entity.status,
      engagements: entity.engagements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date_created': dateCreated.toIso8601String(),
      'type': type,
      'no_engagement': noEngagement,
      'date_updated': dateUpdated.toIso8601String(),
      'status': status,
      'engagements': engagements
          .map((e) => EngagementModel.fromEntity(e).toJson())
          .toList(),
    };
  }
}
