import 'package:fpdart/fpdart.dart';
import 'package:tisini/core/error/exceptions.dart';
import 'package:tisini/core/error/failures.dart';
import 'package:tisini/features/events/data/datasources/ticket_remote_source.dart';
import 'package:tisini/features/events/domain/repositories/ticket_repository.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteSource remoteSource;

  const TicketRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, String>> scanTicket(
    String ticketCode,
    String token,
    String method,
  ) async {
    try {
      final data = await remoteSource.scanTicket(ticketCode, token, method);
      return Right(data);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({String message, String ticketCode})>> createTicket(
    String firstName,
    String lastName,
    String email,
    String phone,
    String quantity,
    String eventId,
    String ticketId,
    String token,
  ) async {
    try {
      final result = await remoteSource.createTicket(
        firstName,
        lastName,
        email,
        phone,
        quantity,
        eventId,
        ticketId,
        token,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
