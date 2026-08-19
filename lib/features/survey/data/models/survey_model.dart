import 'package:tisini/features/survey/data/models/questions_model.dart';
import 'package:tisini/features/survey/domain/entities/questions.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';

class SurveyModel extends Survey {
  SurveyModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.type,
    required super.playMode,
    required super.status,
    required super.startsAt,
    required super.endsAt,
    required super.isPublic,
    required super.isPayable,
    required super.amountPayable,
    required super.prizeDescription,
    required super.company,
    required super.match,
    super.questions = const [],
  });

  SurveyModel copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    String? type,
    String? playMode,
    String? status,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isPublic,
    bool? isPayable,
    String? amountPayable,
    String? prizeDescription,
    int? company,
    int? match,
    List<Questions>? questions,
  }) => SurveyModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    type: type ?? this.type,
    playMode: playMode ?? this.playMode,
    status: status ?? this.status,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    isPublic: isPublic ?? this.isPublic,
    isPayable: isPayable ?? this.isPayable,
    amountPayable: amountPayable ?? this.amountPayable,
    prizeDescription: prizeDescription ?? this.prizeDescription,
    company: company ?? this.company,
    match: match ?? this.match,
    questions: questions ?? this.questions,
  );

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    final questionsRaw = json['questions'];
    final questions = questionsRaw is List
        ? questionsRaw
              .whereType<Map>()
              .map((e) => QuestionsModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <Questions>[];

    return SurveyModel(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      playMode: (json['play_mode'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      startsAt: _parseDateTime(json['starts_at']),
      endsAt: _parseDateTime(json['ends_at']),
      isPublic: _toBool(json['is_public']),
      isPayable: _toBool(json['is_payable']),
      amountPayable: (json['amount_payable'] ?? '0').toString(),
      prizeDescription: (json['prize_description'] ?? '').toString(),
      company: _toInt(json['company']),
      match: _toInt(json['match']),
      questions: questions,
    );
  }

  factory SurveyModel.fromEntity(Survey entity) {
    return SurveyModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      type: entity.type,
      playMode: entity.playMode,
      status: entity.status,
      startsAt: entity.startsAt,
      endsAt: entity.endsAt,
      isPublic: entity.isPublic,
      isPayable: entity.isPayable,
      amountPayable: entity.amountPayable,
      prizeDescription: entity.prizeDescription,
      company: entity.company,
      match: entity.match,
      questions: entity.questions
          .map((q) => q is QuestionsModel ? q : QuestionsModel.fromEntity(q))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'type': type,
      'play_mode': playMode,
      'status': status,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'is_public': isPublic,
      'is_payable': isPayable,
      'amount_payable': amountPayable,
      'prize_description': prizeDescription,
      'company': company,
      'match': match,
      if (questions.isNotEmpty)
        'questions': questions
            .map((q) => QuestionsModel.fromEntity(q).toJson())
            .toList(),
    };
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
  }
}
