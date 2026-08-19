import 'package:dio/dio.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/services/http_response_body.dart';
import 'package:tisini/core/services/http_service.dart';
import 'package:tisini/features/match_capture/data/models/event_category_model.dart';
import 'package:tisini/features/match_capture/data/models/metric_model.dart';
import 'package:tisini/features/match_capture/data/models/match_score_model.dart';
import 'package:tisini/features/match_capture/data/models/match_event_model.dart';
import 'package:tisini/features/match_capture/data/models/lineup_model.dart';
import 'package:tisini/features/match_capture/data/models/player_model.dart';
import 'package:tisini/features/match_capture/data/models/agent_arrival_model.dart';
import 'package:tisini/features/match_capture/data/models/sop_model.dart';

abstract interface class MatchCaptureRemoteSource {
  Future<List<MetricModel>> getMatchMetrics({required String fixtureType});

  Future<List<MatchEventModel>> getMatchEvents({
    required String fixtureId,
    bool isCritical = false,
    bool isLastTen = false,
  });

  Future<List<MatchEventCategoryModel>> getMatchEventCategories({
    required String fixtureType,
  });

  Future<String> createMatchEvent({
    required String fixtureId,
    required bool addOwnGoal,
    required Map<String, dynamic> matchEvent,
  });

  Future<MatchEventModel> updateMatchEvent({
    required String fixtureId,
    required String eventId,
    required Map<String, dynamic> matchEvent,
  });

  Future<String> deleteMatchEvent({
    required String fixtureId,
    required String eventId,
  });

  Future<String> startMatch({required String token, required String fixtureId});

  Future<String> endHalf({
    required String token,
    required String fixtureId,
    required String minute,
    required String second,
    required String status,
    required String moment,
  });

  Future<MatchScoreModel> getMatchScore({required String fixtureId});

  Future<List<LineupModel>> getTeamLineup({
    required String fixtureId,
    required String teamId,
  });

  Future<List<TeamPlayerModel>> getTeamPlayers({required String teamId});

  Future<TeamPlayerModel> updateTeamPlayer({
    required String teamId,
    required String playerId,
    required Map<String, dynamic> player,
  });

  Future<TeamPlayerModel> addPlayer({
    required String teamId,
    required Map<String, dynamic> body,
  });

  Future<List<LineupModel>> saveLineup({
    required String token,
    required String fixtureId,
    required String teamId,
    required List<Map<String, dynamic>> lineups,
  });

  Future<List<LineupModel>> swapPlayers({
    required String teamId,
    required String fixtureId,
    required List<Map<String, int>> players,
  });

  Future<SopModel> getSop({required String fixtureId});

  Future<SopModel> createSop({
    required String fixtureId,
    required Map<String, dynamic> sop,
  });

  Future<SopModel> updateSop({
    required String fixtureId,
    required String sopId,
    required Map<String, dynamic> sop,
  });

  Future<AgentArrivalModel> getAgentArrival({required String fixtureId});

  Future<AgentArrivalModel> createAgentArrival({
    required String fixtureId,
    required Map<String, dynamic> arrival,
  });

  Future<String> uploadImage({required String path});
}

class MatchCaptureRemoteSourceImpl implements MatchCaptureRemoteSource {
  final HttpService _httpService;

  MatchCaptureRemoteSourceImpl({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  @override
  Future<List<MetricModel>> getMatchMetrics({
    required String fixtureType,
  }) async {
    final response = await _httpService.get(
      '/metrics?fixture_type=$fixtureType&with_details=true',
    );

    HttpResponseBody.throwIfHttpError(response);
    final List<dynamic> resData = HttpResponseBody.requireList(response);

    final events = resData
        .map((item) => MetricModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return events;
  }

  @override
  Future<List<MatchEventModel>> getMatchEvents({
    required String fixtureId,
    bool isCritical = false,
    bool isLastTen = false,
  }) async {
    final response = await _httpService.get(
      '/fixtures/$fixtureId/match-events?is_critical=$isCritical&is_last_ten=$isLastTen',
    );

    HttpResponseBody.throwIfHttpError(response);
    final List<dynamic> resData = HttpResponseBody.requireList(response);

    final matchEvents = resData
        .map((item) => MatchEventModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return matchEvents;
  }

  @override
  Future<List<MatchEventCategoryModel>> getMatchEventCategories({
    required String fixtureType,
  }) async {
    final response = await _httpService.get(
      '/metric-categories?fixture_type=$fixtureType',
    );

    HttpResponseBody.throwIfHttpError(response);
    final List<dynamic> resData = HttpResponseBody.requireList(response);

    return resData
        .map(
          (item) =>
              MatchEventCategoryModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<String> createMatchEvent({
    required String fixtureId,
    required bool addOwnGoal,
    required Map<String, dynamic> matchEvent,
  }) async {
    final response = await _httpService.post(
      '/fixtures/$fixtureId/match-events?is_own_goal=$addOwnGoal',
      matchEvent,
    );

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);

    return data['message']?.toString() ?? 'Failed to create event!';
  }

  @override
  Future<String> uploadImage({required String path}) async {
    final filename = path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: filename),
    });

    final response = await _httpService.post('/uploads', formData);

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);
    final url = data['url']?.toString().trim() ?? '';
    if (url.isEmpty) {
      throw ServerException(message: 'Failed to upload image!');
    }
    return url;
  }

  @override
  Future<SopModel> getSop({required String fixtureId}) async {
    final response = await _httpService.get('/fixtures/$fixtureId/sops');

    if (response.statusCode == 404) {
      return const SopModel();
    }

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.asMap(response.data);
    if (data == null || data.isEmpty) {
      return const SopModel();
    }
    return SopModel.fromJson(data);
  }

  @override
  Future<SopModel> createSop({
    required String fixtureId,
    required Map<String, dynamic> sop,
  }) async {
    final response = await _httpService.post(
      '/fixtures/$fixtureId/sops',
      sop,
    );

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.asMap(response.data);
    if (data != null &&
        (data.containsKey('id') || data.containsKey('home_lineup_img'))) {
      return SopModel.fromJson(data);
    }
    return SopModel.fromJson(sop);
  }

  @override
  Future<SopModel> updateSop({
    required String fixtureId,
    required String sopId,
    required Map<String, dynamic> sop,
  }) async {
    final response = await _httpService.patch(
      '/fixtures/$fixtureId/sops/$sopId',
      sop,
    );

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.asMap(response.data);
    if (data != null &&
        (data.containsKey('id') || data.containsKey('home_lineup_img'))) {
      return SopModel.fromJson(data);
    }
    return SopModel.fromJson({...sop, 'id': int.tryParse(sopId) ?? 0});
  }

  @override
  Future<AgentArrivalModel> getAgentArrival({required String fixtureId}) async {
    final response = await _httpService.get(
      '/fixtures/$fixtureId/agent-arrival',
    );

    if (response.statusCode == 404) {
      return const AgentArrivalModel();
    }

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.asMap(response.data);
    if (data == null || data.isEmpty || (data['id'] == null && data['arrival_img'] == null)) {
      return const AgentArrivalModel();
    }
    return AgentArrivalModel.fromJson(data);
  }

  @override
  Future<AgentArrivalModel> createAgentArrival({
    required String fixtureId,
    required Map<String, dynamic> arrival,
  }) async {
    final response = await _httpService.post(
      '/fixtures/$fixtureId/agent-arrivals',
      arrival,
    );

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);
    return AgentArrivalModel.fromJson(data);
  }

  @override
  Future<MatchEventModel> updateMatchEvent({
    required String fixtureId,
    required String eventId,
    required Map<String, dynamic> matchEvent,
  }) async {
    final response = await _httpService.patch(
      '/fixtures/$fixtureId/match-events/$eventId',
      matchEvent,
    );

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);

    return MatchEventModel.fromJson(data);
  }

  @override
  Future<String> deleteMatchEvent({
    required String fixtureId,
    required String eventId,
  }) async {
    final response = await _httpService.delete(
      '/fixtures/$fixtureId/match-events/$eventId',
    );

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);

    return data['message']?.toString() ?? 'Failed to delete event!';
  }

  @override
  Future<String> startMatch({
    required String token,
    required String fixtureId,
  }) async {
    final response = await _httpService.post('/start-match', {
      'fixid': fixtureId,
    });

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);

    return data['message']?.toString() ?? 'Failed to start match!';
  }

  @override
  Future<String> endHalf({
    required String moment,
    required String token,
    required String fixtureId,
    required String minute,
    required String second,
    required String status,
  }) async {
    final response = await _httpService.post('/end-half', {
      "fixture_id": fixtureId,
      "minute": minute,
      "second": second,
      "game_moment": moment,
      "game_status": status,
    });

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);

    return data['message']?.toString() ?? 'Failed to end half!';
  }

  @override
  Future<MatchScoreModel> getMatchScore({required String fixtureId}) async {
    final response = await _httpService.get('/fixtures/$fixtureId/scores');

    HttpResponseBody.throwIfHttpError(response);
    final resData = HttpResponseBody.requireMap(response);

    final scores = MatchScoreModel.fromJson(resData);

    return scores;
  }

  @override
  Future<List<LineupModel>> getTeamLineup({
    required String fixtureId,
    required String teamId,
  }) async {
    final response = await _httpService.get(
      '/fixtures/$fixtureId/lineups?team_id=$teamId',
    );

    HttpResponseBody.throwIfHttpError(response);
    final List<dynamic> resData = HttpResponseBody.requireList(response);

    final lineup = resData
        .map((item) => LineupModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return lineup;
  }

  @override
  Future<List<TeamPlayerModel>> getTeamPlayers({required String teamId}) async {
    final response = await _httpService.get('/teams/$teamId/players');

    HttpResponseBody.throwIfHttpError(response);
    final List<dynamic> resData = HttpResponseBody.requireList(response);

    final players = resData
        .map((item) => TeamPlayerModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return players;
  }

  @override
  Future<TeamPlayerModel> updateTeamPlayer({
    required String teamId,
    required String playerId,
    required Map<String, dynamic> player,
  }) async {
    final response = await _httpService.patch(
      '/teams/$teamId/players/$playerId',
      player,
    );

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);

    return TeamPlayerModel.fromJson(data);
  }

  @override
  Future<TeamPlayerModel> addPlayer({
    required String teamId,
    required Map<String, dynamic> body,
  }) async {
    final payload = {
      "fname": body["firstName"],
      "sname": body["lastName"],
      "oname": body["sirName"] ?? '',
      "playerdob": body["dob"],
      "position": body["position"],
      "phone": body["phone"] ?? '',
      "idno": body["idno"] ?? '',
      "countrycode": body["countrycode"],
      "jersey": body["jersey"],
      "contract": body["contract"],
      "email": body["email"] ?? '',
      "password": "password",
    };

    final response = await _httpService.post('/teams/$teamId/players', payload);

    HttpResponseBody.throwIfHttpError(response);
    final data = HttpResponseBody.requireMap(response);

    return TeamPlayerModel.fromJson(data);
  }

  @override
  Future<List<LineupModel>> saveLineup({
    required String token,
    required String fixtureId,
    required String teamId,
    required List<Map<String, dynamic>> lineups,
  }) async {
    final response = await _httpService.post(
      '/fixtures/$fixtureId/lineups',
      lineups,
    );

    HttpResponseBody.throwIfHttpError(response);
    final List<dynamic> resData = HttpResponseBody.requireList(response);

    final lineup = resData
        .map((item) => LineupModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return lineup;
  }

  @override
  Future<List<LineupModel>> swapPlayers({
    required String teamId,
    required String fixtureId,
    required List<Map<String, int>> players,
  }) async {
    final response = await _httpService.patch(
      '/fixtures/$fixtureId/swap-lineups?team_id=$teamId',
      {"players": players},
    );

    HttpResponseBody.throwIfHttpError(response);
    final List<dynamic> resData = HttpResponseBody.requireList(response);

    final lineup = resData
        .map((item) => LineupModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return lineup;
  }
}
