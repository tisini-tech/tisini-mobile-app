import 'package:get/get.dart';
import 'package:tisini/features/events/data/datasources/ticket_remote_source.dart';
import 'package:tisini/features/events/data/repositories/ticket_repository_impl.dart';
import 'package:tisini/features/events/domain/repositories/ticket_repository.dart';
import 'package:tisini/features/events/domain/usecases/scan_ticket.dart';
import 'package:tisini/features/events/presentation/controllers/events_controller.dart';

class EventsBinding extends Bindings {
  @override
  void dependencies() {
    // data layer
    Get.lazyPut<TicketRemoteSource>(() => TicketRemoteSourceImpl());
    Get.lazyPut<TicketRepository>(
      () => TicketRepositoryImpl(remoteSource: Get.find()),
    );

    // domain layer
    Get.lazyPut(() => ScanTicketUsecase(repository: Get.find()));

    // presentation layer
    Get.lazyPut(() => EventsController(scanTicketUsecase: Get.find()));
  }
}
