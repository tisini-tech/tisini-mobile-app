class Questions {
  final List<Choice> choices;
  final int id;
  final String answerType;
  final String text;
  final int order;
  final String imageUrl;
  final int points;
  final int timerSeconds;
  final bool isRequired;
  final int team;
  final int metric;
  final int metricDetail;

  Questions({
    required this.choices,
    required this.id,
    required this.answerType,
    required this.text,
    required this.order,
    required this.imageUrl,
    required this.points,
    required this.timerSeconds,
    required this.isRequired,
    required this.team,
    required this.metric,
    required this.metricDetail,
  });
}

class Choice {
  final int id;
  final String text;
  final int team;

  Choice({required this.id, required this.text, required this.team});
}
