import 'dart:convert';

import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/services/tickets_http_service.dart';

abstract interface class TicketRemoteSource {
  Future<String> scanTicket(String ticketCode, String token, String method);

  /// Returns (message, ticketCode) on success; [ticketCode] is the M-Pesa account number.
  Future<({String message, String ticketCode})> createTicket(
    String firstName,
    String lastName,
    String email,
    String phone,
    String quantity,
    String eventId,
    String ticketId,
    String token,
  );
}

class TicketRemoteSourceImpl implements TicketRemoteSource {
  final TicketsHttpService _httpService;

  TicketRemoteSourceImpl({TicketsHttpService? httpService})
    : _httpService = httpService ?? TicketsHttpService();

  @override
  Future<String> scanTicket(
    String ticketCode,
    String token,
    String method,
  ) async {
    final response = await _httpService.post('gettoken=$token', {
      "action": "verify_ticket_purchased",
      "ticket_code": ticketCode,
      "vmethod": method,
    });

    if (response == null) {
      throw ServerException(
        message: 'No response from server. Check connectivity.',
      );
    }

    final raw = response.data;
    final data = raw is String
        ? Map<String, dynamic>.from(json.decode(raw) as Map)
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : null;

    if (data == null || data.isEmpty) {
      throw ServerException(message: 'Invalid response from server.');
    }

    // API: error "0" = success, "1" = failure (with message)
    final error = data['error']?.toString();
    if (error == '1') {
      throw ServerException(
        message: data['message']?.toString() ?? 'Ticket verification failed.',
      );
    }

    return data['message']?.toString() ?? 'Ticket Verified';
  }

  @override
  Future<({String message, String ticketCode})> createTicket(
    String firstName,
    String lastName,
    String email,
    String phone,
    String quantity,
    String eventId,
    String ticketId,
    String token,
  ) async {
    final response = await _httpService.post('gettoken=$token', {
      "action": "create_ticket_purchaser",
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "quantity": quantity,
      "amount": "0",
      "ticket_package_id": ticketId,
      "ticket_activity_id": eventId,
      "is_verified": "0",
    });

    if (response == null) {
      throw ServerException(
        message: 'No response from server. Check connectivity.',
      );
    }

    print('response: $response');
    print(response.data);

    final raw = response.data;
    final data = raw is String
        ? Map<String, dynamic>.from(json.decode(raw) as Map)
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : null;

    if (data == null || data.isEmpty) {
      throw ServerException(message: 'Invalid response from server.');
    }

    final error = data['error']?.toString();
    if (error == '1') {
      throw ServerException(
        message: data['message']?.toString() ?? 'Ticket creation failed.',
      );
    }

    final message =
        data['message']?.toString() ?? 'Ticket created successfully';
    final ticketCode = data['ticket_code']?.toString() ?? '';
    return (message: message, ticketCode: ticketCode);
  }
}
