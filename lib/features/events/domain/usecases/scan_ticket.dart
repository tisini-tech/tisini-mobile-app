import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/core/usecase/usecase.dart';
import 'package:tisini/features/events/domain/repositories/ticket_repository.dart';

class ScanTicketUsecase implements UseCase<String, ScanTicketParams> {
  final TicketRepository repository;

  ScanTicketUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(ScanTicketParams params) async {
    return await repository.scanTicket(
      params.ticketCode,
      params.token,
      params.method,
    );
  }
}

class ScanTicketParams {
  final String ticketCode;
  final String token;
  final String method;

  ScanTicketParams({
    required this.ticketCode,
    required this.token,
    required this.method,
  });
}
