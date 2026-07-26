import 'package:tisini/features/survey/domain/entities/engagement.dart';

class Survey {
  String id;
  String title;
  DateTime dateCreated;
  String type;
  String noEngagement;
  DateTime dateUpdated;
  String status;
  List<Engagement> engagements;

  Survey({
    required this.id,
    required this.title,
    required this.dateCreated,
    required this.type,
    required this.noEngagement,
    required this.dateUpdated,
    required this.status,
    required this.engagements,
  });
}
