import 'package:tisini/features/survey/domain/entities/questions.dart';

class Survey {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String type;
  final String playMode;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isPublic;
  final bool isPayable;
  final String amountPayable;
  final String prizeDescription;
  final int company;
  final int match;

  /// Present on `/engagements/{id}/questions`; empty for list endpoints.
  final List<Questions> questions;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.playMode,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.isPublic,
    required this.isPayable,
    required this.amountPayable,
    required this.prizeDescription,
    required this.company,
    required this.match,
    this.questions = const [],
  });
}
