import 'package:tisini/features/survey/domain/entities/survey_response_item.dart';

/// A full survey submission stored locally, to be uploaded when online.
class PendingSurveySubmission {
  final String id;
  final List<SurveyResponseItem> responses;
  final DateTime createdAt;
  final bool synced;

  const PendingSurveySubmission({
    required this.id,
    required this.responses,
    required this.createdAt,
    this.synced = false,
  });
}
