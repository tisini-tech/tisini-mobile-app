import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/events/domain/repositories/ticket_repository.dart';

/// Result of successful ticket creation; [ticketCode] is used as M-Pesa account number.
typedef CreateTicketResult = ({String message, String ticketCode});

class CreateTicketUsecase implements UseCase<CreateTicketResult, CreateTicketParams> {
  final TicketRepository repository;

  CreateTicketUsecase({required this.repository});

  @override
  Future<Either<Failure, CreateTicketResult>> call(CreateTicketParams params) async {
    return await repository.createTicket(
      params.firstName,
      params.lastName,
      params.email,
      params.phone,
      params.quantity,
      params.eventId,
      params.ticketId,
      params.token,
    );
  }
}

class CreateTicketParams {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String quantity;
  final String eventId;
  final String ticketId;
  final String token;

  CreateTicketParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.quantity,
    required this.eventId,
    required this.ticketId,
    required this.token,
  });
}
