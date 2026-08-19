import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/match_capture/data/models/lineup_model.dart';
import 'package:tisini/features/match_capture/data/models/player_model.dart';
import 'package:tisini/features/match_capture/domain/entities/new_player_input.dart';
import 'package:tisini/features/match_capture/domain/usecases/add_player.dart';
import 'package:tisini/features/match_capture/domain/usecases/team_lineup.dart';
import 'package:tisini/features/match_capture/domain/entities/lineup.dart';
import 'package:tisini/features/match_capture/domain/entities/player.dart';
import 'package:tisini/features/match_capture/domain/usecases/team_players.dart';
import 'package:tisini/features/match_capture/domain/usecases/save_lineup.dart';
import 'package:tisini/features/match_capture/presentation/pages/add_player_screen.dart';
import 'package:tisini/features/match_capture/presentation/widgets/saved_lineup_preview.dart';

class LineupController extends GetxController {
  static LineupController get instance => Get.find();

  final TeamPlayersUsecase teamPlayersUsecase;
  final TeamLineupUsecase teamLineupUsecase;
  final SaveLineupUsecase saveLineupUsecase;
  final AddPlayerUsecase addPlayerUsecase;
  final UpdateTeamPlayerUsecase updateTeamPlayerUsecase;

  LineupController({
    required this.teamPlayersUsecase,
    required this.teamLineupUsecase,
    required this.saveLineupUsecase,
    required this.addPlayerUsecase,
    required this.updateTeamPlayerUsecase,
  });

  final box = GetStorage();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxMap<String, String> team = <String, String>{}.obs;
  final Rx<AgentFixture?> fixture = Rx<AgentFixture?>(null);
  final RxList<TeamPlayer> players = <TeamPlayer>[].obs;
  final RxList<Lineup> lineup = <Lineup>[].obs;
  final RxList<TeamPlayer> starters = <TeamPlayer>[].obs;
  final RxList<TeamPlayer> substitutes = <TeamPlayer>[].obs;

  /// Search query for filtering players by name.
  final RxString searchQuery = ''.obs;

  // --- Add player form ---
  final addPlayerFormKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final sirNameController = TextEditingController();
  final dobController = TextEditingController();
  final RxnString selectedPosition = RxnString();
  final phoneController = TextEditingController();
  final idnoController = TextEditingController();
  final jerseyController = TextEditingController();
  final contractController = TextEditingController();
  final emailController = TextEditingController();

  final RxString countryCode = '+254'.obs;
  final RxBool isAddingPlayer = false.obs;

  static const List<Map<String, String>> countryCodes = [
    {'code': '+254', 'label': 'KE +254'},
    {'code': '+255', 'label': 'TZ +255'},
    {'code': '+256', 'label': 'UG +256'},
    {'code': '+250', 'label': 'RW +250'},
    {'code': '+1', 'label': 'US +1'},
    {'code': '+44', 'label': 'UK +44'},
  ];

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map && args['team'] is Map<String, String>) {
      final team = args['team'] as Map<String, String>;
      this.team.value = team;
    }

    if (args is Map && args['fixture'] is AgentFixture) {
      fixture.value = args['fixture'] as AgentFixture;
    }

    lineup.clear();
    starters.clear();
    substitutes.clear();
    players.clear();

    loadData();
  }

  Future<String?> getToken() async {
    return box.read('token') as String?;
  }

  void goToAddPlayerScreen() {
    Get.to(() => const AddPlayerScreen(), fullscreenDialog: true);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    sirNameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    idnoController.dispose();
    jerseyController.dispose();
    contractController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void setCountryCode(String? value) {
    countryCode.value = value ?? '+254';
  }

  void resetAddPlayerForm() {
    addPlayerFormKey.currentState?.reset();
    firstNameController.clear();
    lastNameController.clear();
    sirNameController.clear();
    dobController.clear();
    selectedPosition.value = null;
    phoneController.clear();
    idnoController.clear();
    jerseyController.clear();
    contractController.clear();
    emailController.clear();
    countryCode.value = '+254';
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? validateOptionalEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(trimmed)) return 'Enter a valid email';
    return null;
  }

  Future<void> pickDate(
    BuildContext context, {
    required TextEditingController target,
    DateTime? initial,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      target.text = _formatApiDate(picked);
    }
  }

  static String _formatApiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void setSearchQuery(String query) {
    searchQuery.value = query.trim();
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  /// Players filtered by search (name, case-insensitive). Empty query = all players.
  List<TeamPlayer> get filteredPlayers {
    final q = searchQuery.value;
    if (q.isEmpty) return players;
    final lower = q.toLowerCase();
    return players
        .where((p) => p.player.name.toLowerCase().contains(lower))
        .toList();
  }

  void loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([getTeamPlayers(), getTeamLineup()]);
    } catch (e) {
      isLoading.value = false;
      showSnackbar('Error', 'Failed to load data', TColors.error);
    } finally {
      isLoading.value = false;
    }
  }

  int maxStarters() {
    final fixtureType = fixture.value?.fixtureType ?? '';

    if (fixtureType == "football") {
      return 11;
    } else if (fixtureType == "rugby7") {
      return 7;
    } else if (fixtureType == "rugby15") {
      return 15;
    } else if (fixtureType == "rugby10") {
      return 10;
    } else if (fixtureType == "basketball") {
      return 5;
    }

    return 0;
  }

  /// Returns a user-facing message when lineup selection is incomplete.
  String? lineupValidationMessage() {
    final requiredStarters = maxStarters();
    if (requiredStarters == 0) {
      return 'Cannot save lineup: unknown fixture type';
    }
    if (starters.length != requiredStarters) {
      return 'Select exactly $requiredStarters starters '
          '(${starters.length} selected)';
    }
    if (substitutes.isEmpty) {
      return 'Select at least one substitute';
    }
    return null;
  }

  void setStarter(TeamPlayer player) {
    substitutes.removeWhere((p) => p.id == player.id);

    if (starters.any((p) => p.id == player.id)) return;
    if (starters.length >= maxStarters()) {
      showSnackbar('Limit', 'Maximum ${maxStarters()} starters', TColors.error);
      return;
    }
    starters.add(player);
  }

  void setSubstitute(TeamPlayer player) {
    starters.removeWhere((p) => p.id == player.id);

    if (substitutes.any((p) => p.id == player.id)) return;
    if (substitutes.length >= 50) {
      showSnackbar('Limit', 'Maximum 50 substitutes', TColors.error);
      return;
    }
    substitutes.add(player);
  }

  void clearRole(TeamPlayer player) {
    starters.removeWhere((p) => p.id == player.id);
    substitutes.removeWhere((p) => p.id == player.id);
  }

  /// Updates player name parts, position, and jersey via API, then patches local state.
  Future<void> updateSavedPlayer(
    Lineup player,
    SavedLineupPlayerEdit edit,
  ) async {
    final result = await updateTeamPlayerUsecase.call(
      UpdateTeamPlayerParams(
        teamId: team['id'] ?? '',
        playerId: player.teamPlayer.toString(),
        player: {
          'fname': edit.firstName,
          'sname': edit.lastName,
          'oname': edit.surname,
          'position': edit.position,
          'jersey': edit.jerseyNumber.toString(),
          'fixture_id': fixture.value?.id.toString() ?? '',
        },
      ),
    );

    result.fold(
      (failure) {
        showSnackbar('Player update error', failure.message, TColors.error);
      },
      (updated) {
        final name = edit.fullName.isNotEmpty
            ? edit.fullName
            : updated.player.name;
        final position = edit.position.isNotEmpty
            ? edit.position
            : updated.player.currentPosition;

        final lineupIndex = lineup.indexWhere((p) => p.id == player.id);
        if (lineupIndex >= 0) {
          final current = lineup[lineupIndex];
          lineup[lineupIndex] = LineupModel.fromEntity(current).copyWith(
            player: PlayerModel.fromEntity(
              current.player,
            ).copyWith(name: name, currentPosition: position),
            jerseyNumber: edit.jerseyNumber,
          );
        }

        final rosterIndex = players.indexWhere(
          (p) => p.id == updated.id || p.id == player.teamPlayer,
        );
        if (rosterIndex >= 0) {
          final current = players[rosterIndex];
          players[rosterIndex] = TeamPlayerModel.fromEntity(current).copyWith(
            player: PlayerModel.fromEntity(
              current.player,
            ).copyWith(name: name, currentPosition: position),
            currentJerseyNo: edit.jerseyNumber,
          );
        }

        showSnackbar(
          'Player updated',
          '$name · #${edit.jerseyNumber}',
          TColors.success,
        );
      },
    );
  }

  Future<void> getTeamPlayers() async {
    final teamId = team['id'] ?? '';

    final result = await teamPlayersUsecase.call(
      TeamPlayersParams(teamId: teamId),
    );

    result.fold(
      (failure) {
        isLoading.value = false;
        showSnackbar('Team players', failure.message, TColors.error);
      },
      (data) {
        players.assignAll(data);
      },
    );
  }

  Future<void> getTeamLineup() async {
    final token = await getToken();
    final teamId = team['id'] ?? '';
    final fixtureId = fixture.value?.id;

    if (token == null || token.isEmpty || teamId.isEmpty) return;

    final result = await teamLineupUsecase.call(
      TeamLineupParams(
        token: token,
        fixtureId: fixtureId.toString(),
        teamId: teamId,
      ),
    );

    result.fold(
      (failure) {
        showSnackbar('Lineup Error', failure.message, TColors.error);
      },
      (list) {
        lineup.assignAll(list);
      },
    );
  }

  void saveLineup() async {
    final validationMessage = lineupValidationMessage();
    if (validationMessage != null) {
      showSnackbar('Lineup', validationMessage, TColors.error);
      return;
    }

    isSaving.value = true;

    final token = await getToken();
    if (token == null || token.isEmpty) {
      isSaving.value = false;
      return;
    }

    final teamId = team['id'] ?? '';
    final matchId = fixture.value?.id ?? 0;
    final parsedTeamId = int.tryParse(teamId) ?? 0;

    if (teamId.isEmpty || matchId == 0) {
      isSaving.value = false;
      showSnackbar('Lineup', 'Missing match or team', TColors.error);
      return;
    }

    final lineups = <Map<String, dynamic>>[
      ...starters.asMap().entries.map(
        (entry) => TeamPlayerModel.lineupSavePayload(
          teamPlayer: entry.value,
          teamId: parsedTeamId,
          lineupPosition: entry.key + 1,
          role: 'first11',
        ),
      ),
      ...substitutes.map(
        (player) => TeamPlayerModel.lineupSavePayload(
          teamPlayer: player,
          teamId: parsedTeamId,
          lineupPosition: TeamPlayerModel.substituteLineupPosition,
          role: 'sub',
        ),
      ),
    ];

    final result = await saveLineupUsecase.call(
      SaveLineupParams(
        token: token,
        fixtureId: matchId.toString(),
        teamId: teamId,
        lineups: lineups,
      ),
    );

    result.fold(
      (failure) => showSnackbar('Lineup', failure.message, TColors.error),
      (data) {
        showSnackbar('Lineup', "Lineup saved successfully", TColors.success);
        lineup.assignAll(data);
      },
    );

    isSaving.value = false;
  }

  Future<void> submitAddPlayer() async {
    if (!(addPlayerFormKey.currentState?.validate() ?? false)) return;

    final teamId = team['id'] ?? '';
    if (teamId.isEmpty) {
      showSnackbar('Error', 'Missing team', TColors.error);
      return;
    }

    isAddingPlayer.value = true;

    final input = NewPlayerInput(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      sirName: sirNameController.text.trim(),
      dob: dobController.text.trim(),
      position: selectedPosition.value?.trim() ?? '',
      countrycode: countryCode.value,
      jersey: jerseyController.text.trim(),
      contract: contractController.text.trim(),
      phone: phoneController.text.trim(),
      idno: idnoController.text.trim(),
      email: emailController.text.trim(),
    );

    final result = await addPlayerUsecase.call(
      AddPlayerParams(teamId: teamId, player: input),
    );

    isAddingPlayer.value = false;

    result.fold(
      (failure) => showSnackbar('Add player', failure.message, TColors.error),
      (player) async {
        resetAddPlayerForm();
        players.add(player);
        Get.back();
        showSnackbar(
          'Add player',
          '${player.player.name} added successfully',
          TColors.success,
        );
      },
    );
  }
}
