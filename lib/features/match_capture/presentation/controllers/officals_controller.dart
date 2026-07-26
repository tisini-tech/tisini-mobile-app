import 'package:get/get.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';

class MatchOfficialsController extends GetxController {
  static MatchOfficialsController get instance => Get.find();

  final Rx<AgentFixture?> fixture = Rx<AgentFixture?>(null);

  /// Official role labels in display order.
  static const List<String> officialRoles = [
    'Match Commissioner',
    'Referee',
    'Assistant Referee 1',
    'Assistant Referee 2',
    'Reserve Referee',
  ];

  /// Names per role (key = role, value = name). Populate from API or leave empty.
  final RxMap<String, String> officialNames = <String, String>{}.obs;

  /// All officials available to assign (e.g. from API or added via modal).
  final RxList<String> officialsList = <String>[].obs;

  /// Search query for filtering officials in SelectOfficials.
  final Rx<String> searchQuery = ''.obs;

  /// Currently selected official name in SelectOfficials (for the bottom button).
  final Rx<String?> selectedOfficial = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is AgentFixture) {
      fixture.value = args;
    } else if (args is Map && args['fixture'] is AgentFixture) {
      fixture.value = args['fixture'] as AgentFixture;
    } else {
      fixture.value = null;
    }
  }

  String nameForRole(String role) => officialNames[role] ?? '';

  /// Filtered list of officials for the current search.
  List<String> get filteredOfficials {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return List<String>.from(officialsList);
    return officialsList
        .where((name) => name.toLowerCase().contains(q))
        .toList();
  }

  /// Assign the given official name to the role and persist for this fixture.
  void assignOfficialToRole(String role, String officialName) {
    officialNames[role] = officialName;
    selectedOfficial.value = null;
  }

  /// Add an official to the list (e.g. from "Add" modal). Updates officials list.
  void addOfficial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (!officialsList.contains(trimmed)) {
      officialsList.add(trimmed);
    }
  }

  void clearSelection() => selectedOfficial.value = null;
}
