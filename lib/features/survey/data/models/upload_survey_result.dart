/// Result of uploading pending surveys to the server.
class UploadSurveyResult {
  final String message;
  final List<String> surveyIds;

  const UploadSurveyResult({
    required this.message,
    required this.surveyIds,
  });
}
