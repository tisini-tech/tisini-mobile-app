class EventCategories {
  EventCategories._();

  static const List<({String id, String label})> footballCategories = [
    (id: '3', label: 'Defense'),
    (id: '4', label: 'Possession'),
    (id: '5', label: 'Attack'),
    (id: '6', label: 'Goalkeeping'),
    (id: '1', label: 'Discipline'),
    (id: '7', label: 'General'),
  ];

  static const List<({String id, String label})> rugby15Categories = [
    (id: '8', label: 'Attack'),
    (id: '9', label: 'Defense'),
    (id: '10', label: 'Discipline'),
    (id: '11', label: 'Set Piece'),
    (id: '12', label: 'Possession'),
    (id: '13', label: 'Territory'),
    (id: '14', label: 'Territorial kicks'),
    (id: '15', label: 'General'),
  ];

  /// Same grouping as rugby 15s until API exposes distinct rugby7 category ids.
  static const List<({String id, String label})> rugby7Categories =
      rugby15Categories;

  /// Rugby 10s uses the same stat category ids as 15s.
  static const List<({String id, String label})> rugby10Categories =
      rugby15Categories;

  /// Adjust ids when backend defines basketball-specific stat categories.
  static const List<({String id, String label})> basketballCategories = [];
}
