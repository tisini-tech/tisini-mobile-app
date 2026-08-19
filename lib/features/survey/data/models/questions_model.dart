import 'package:tisini/features/survey/domain/entities/questions.dart';

class QuestionsModel extends Questions {
  QuestionsModel({
    required super.choices,
    required super.id,
    required super.answerType,
    required super.text,
    required super.order,
    required super.imageUrl,
    required super.points,
    required super.timerSeconds,
    required super.isRequired,
    required super.team,
    required super.metric,
    required super.metricDetail,
  });

  factory QuestionsModel.fromJson(Map<String, dynamic> json) {
    final choicesRaw = json['choices'];
    final choices = choicesRaw is List
        ? choicesRaw
              .whereType<Map>()
              .map((e) => ChoiceModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <Choice>[];

    return QuestionsModel(
      choices: choices,
      id: _toInt(json['id']),
      answerType: (json['answer_type'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      order: _toInt(json['order']),
      imageUrl: (json['image_url'] ?? '').toString(),
      points: _toInt(json['points']),
      timerSeconds: _toInt(json['timer_seconds']),
      isRequired: _toBool(json['is_required']),
      team: _toInt(json['team']),
      metric: _toInt(json['metric']),
      metricDetail: _toInt(json['metric_detail']),
    );
  }

  factory QuestionsModel.fromEntity(Questions entity) {
    return QuestionsModel(
      choices: entity.choices
          .map((c) => c is ChoiceModel ? c : ChoiceModel.fromEntity(c))
          .toList(),
      id: entity.id,
      answerType: entity.answerType,
      text: entity.text,
      order: entity.order,
      imageUrl: entity.imageUrl,
      points: entity.points,
      timerSeconds: entity.timerSeconds,
      isRequired: entity.isRequired,
      team: entity.team,
      metric: entity.metric,
      metricDetail: entity.metricDetail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer_type': answerType,
      'text': text,
      'order': order,
      'image_url': imageUrl,
      'points': points,
      'timer_seconds': timerSeconds,
      'is_required': isRequired,
      'team': team,
      'metric': metric,
      'metric_detail': metricDetail,
      'choices': choices
          .map((c) => ChoiceModel.fromEntity(c).toJson())
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
}

class ChoiceModel extends Choice {
  ChoiceModel({required super.id, required super.text, required super.team});

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      id: QuestionsModel._toInt(json['id']),
      text: (json['text'] ?? '').toString(),
      team: QuestionsModel._toInt(json['team']),
    );
  }

  factory ChoiceModel.fromEntity(Choice entity) {
    return ChoiceModel(id: entity.id, text: entity.text, team: entity.team);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'team': team};
  }
}
