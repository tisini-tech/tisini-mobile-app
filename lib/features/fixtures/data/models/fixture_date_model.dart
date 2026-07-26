import 'package:tisini/features/fixtures/domain/entities/fixture_date.dart';

class FixtureDateModel extends FixtureDate {
  FixtureDateModel({required super.dates});

  factory FixtureDateModel.fromJson(List<dynamic> json) {
    final dates = json.map((date) => date.toString()).toList();
    return FixtureDateModel(dates: dates);
  }

  List<String> toJson() => dates;
}
