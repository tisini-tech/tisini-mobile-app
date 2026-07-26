import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';

abstract interface class TicketRepository {
  // Future<void> createTicket(Ticket ticket);
  Future<Either<Failure, String>> scanTicket(
    String ticketCode,
    String token,
    String method,
  );

  Future<Either<Failure, ({String message, String ticketCode})>> createTicket(
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
