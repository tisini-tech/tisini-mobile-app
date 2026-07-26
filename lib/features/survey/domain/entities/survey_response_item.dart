/// A single answer in a survey submission.
class SurveyResponseItem {
  final int questionId;
  final dynamic value; // String or List<String> for multiple choice

  const SurveyResponseItem({
    required this.questionId,
    required this.value,
  });
}
