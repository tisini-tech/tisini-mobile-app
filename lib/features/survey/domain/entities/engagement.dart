class Engagement {
  String id;
  String titleId;
  String question;
  String type;
  String isRequired;
  String placeholder;
  String multiline;
  List<String> options;
  String multiple;
  String helpText;
  dynamic maxSelections;
  String layout;
  String other;
  dynamic fields;

  Engagement({
    required this.id,
    required this.titleId,
    required this.question,
    required this.type,
    required this.isRequired,
    required this.placeholder,
    required this.multiline,
    required this.options,
    required this.multiple,
    required this.helpText,
    required this.maxSelections,
    required this.layout,
    required this.other,
    required this.fields,
  });
}
