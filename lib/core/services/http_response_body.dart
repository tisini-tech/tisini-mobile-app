import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tisini/core/error/exceptions.dart';

/// Parses Django REST Framework JSON responses from [Response.data].
class HttpResponseBody {
  HttpResponseBody._();

  /// Throws [ServerException] when status is 4xx/5xx.
  /// Reads DRF error shapes: `detail` (string or list) and field errors.
  static void throwIfHttpError(
    Response response, {
    String fallback = 'Request failed',
  }) {
    final status = response.statusCode ?? 0;
    if (status < 400) return;

    throw ServerException(
      message: errorMessage(
        response.data,
        fallback: fallback,
        statusCode: response.statusCode,
      ),
    );
  }

  /// Success body as a JSON object (e.g. login, detail views).
  static Map<String, dynamic> requireMap(
    Response response, {
    String message = 'Invalid response from server.',
  }) {
    final map = asMap(response.data);
    if (map == null || map.isEmpty) {
      throw ServerException(message: message);
    }
    return map;
  }

  /// Paginated list: `{ "count", "next", "previous", "results": [...] }`.
  static List<Map<String, dynamic>> requireResults(
    Response response, {
    String message = 'Invalid response from server.',
  }) {
    final map = requireMap(response, message: message);
    final results = map['results'];
    if (results is! List) {
      throw ServerException(message: message);
    }
    return _mapsFromList(results, message: message);
  }

  /// Bare JSON array `[...]` (unpaginated DRF list endpoints).
  static List<Map<String, dynamic>> requireList(
    Response response, {
    String message = 'Invalid response from server.',
  }) {
    final list = asList(response.data);
    if (list == null) {
      throw ServerException(message: message);
    }
    return _mapsFromList(list, message: message);
  }

  /// List body as `[...]` or paginated `{ "results": [...] }`.
  static List<Map<String, dynamic>> requireListOrResults(
    Response response, {
    String message = 'Invalid response from server.',
  }) {
    final list = asList(response.data);
    if (list != null) return _mapsFromList(list, message: message);

    final map = asMap(response.data);
    if (map != null && map['results'] is List) {
      return _mapsFromList(map['results'] as List, message: message);
    }

    throw ServerException(message: message);
  }

  static List<dynamic>? asList(dynamic raw) {
    if (raw is List) return List<dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      final decoded = json.decode(raw);
      if (decoded is List) return List<dynamic>.from(decoded);
    }
    return null;
  }

  static List<Map<String, dynamic>> _mapsFromList(
    List list, {
    required String message,
  }) {
    try {
      return list
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      throw ServerException(message: message);
    }
  }

  static Map<String, dynamic>? asMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      final decoded = json.decode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return null;
  }

  static String errorMessage(
    dynamic raw, {
    String fallback = 'Request failed',
    int? statusCode,
  }) {
    final map = asMap(raw);
    if (map == null) {
      return statusCode != null ? '$fallback ($statusCode)' : fallback;
    }

    final detail = map['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) {
      return detail.map((e) => e.toString()).join('\n');
    }

    final fieldMessages = <String>[];
    for (final entry in map.entries) {
      if (entry.key == 'detail') continue;
      final text = _fieldErrorText(entry.key, entry.value);
      if (text != null) fieldMessages.add(text);
    }
    if (fieldMessages.isNotEmpty) return fieldMessages.join('\n');

    return statusCode != null ? '$fallback ($statusCode)' : fallback;
  }

  static String? _fieldErrorText(String field, dynamic value) {
    if (value is List && value.isNotEmpty) {
      return '$field: ${value.first}';
    }
    if (value is String && value.isNotEmpty) {
      return '$field: $value';
    }
    return null;
  }
}
