import 'package:tisini/features/survey/domain/entities/engagement.dart';

class EngagementModel extends Engagement {
  EngagementModel({
    required super.id,
    required super.titleId,
    required super.question,
    required super.type,
    required super.isRequired,
    required super.placeholder,
    required super.multiline,
    required super.options,
    required super.multiple,
    required super.helpText,
    required super.maxSelections,
    required super.layout,
    required super.other,
    required super.fields,
  });

  EngagementModel copyWith({
    String? id,
    String? titleId,
    String? question,
    String? type,
    String? isRequired,
    String? placeholder,
    String? multiline,
    List<String>? options,
    String? multiple,
    String? helpText,
    dynamic maxSelections,
    String? layout,
    String? other,
    dynamic fields,
  }) => EngagementModel(
    id: id ?? this.id,
    titleId: titleId ?? this.titleId,
    question: question ?? this.question,
    type: type ?? this.type,
    isRequired: isRequired ?? this.isRequired,
    placeholder: placeholder ?? this.placeholder,
    multiline: multiline ?? this.multiline,
    options: options ?? this.options,
    multiple: multiple ?? this.multiple,
    helpText: helpText ?? this.helpText,
    maxSelections: maxSelections ?? this.maxSelections,
    layout: layout ?? this.layout,
    other: other ?? this.other,
    fields: fields ?? this.fields,
  );

  factory EngagementModel.fromEntity(Engagement entity) {
    return EngagementModel(
      id: entity.id,
      titleId: entity.titleId,
      question: entity.question,
      type: entity.type,
      isRequired: entity.isRequired,
      placeholder: entity.placeholder,
      multiline: entity.multiline,
      options: List<String>.from(entity.options),
      multiple: entity.multiple,
      helpText: entity.helpText,
      maxSelections: entity.maxSelections,
      layout: entity.layout,
      other: entity.other,
      fields: entity.fields,
    );
  }

  factory EngagementModel.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['options'];
    final options = optionsRaw is List
        ? (optionsRaw).map((e) => e.toString()).toList()
        : <String>[];

    return EngagementModel(
      id: (json['id'] ?? '').toString(),
      titleId: (json['title_id'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      isRequired: (json['isRequired'] ?? json['is_required'] ?? '0').toString(),
      placeholder: (json['placeholder'] ?? '').toString(),
      multiline: (json['multiline'] ?? '0').toString(),
      options: options,
      multiple: (json['multiple'] ?? '0').toString(),
      helpText: (json['helpText'] ?? json['help_text'] ?? '').toString(),
      maxSelections: json['maxSelections'] ?? json['max_selections'],
      layout: (json['layout'] ?? '').toString(),
      other: (json['other'] ?? '0').toString(),
      fields: json['fields'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_id': titleId,
      'question': question,
      'type': type,
      'is_required': isRequired,
      'placeholder': placeholder,
      'multiline': multiline,
      'options': options,
      'multiple': multiple,
      'helpText': helpText,
      'maxSelections': maxSelections,
      'layout': layout,
      'other': other,
      'fields': fields,
    };
  }
}
