import 'package:get/get.dart';
import 'package:tisini/features/events/data/datasources/ticket_remote_source.dart';
import 'package:tisini/features/events/data/repositories/ticket_repository_impl.dart';
import 'package:tisini/features/events/domain/repositories/ticket_repository.dart';
import 'package:tisini/features/events/domain/usecases/create_ticket.dart';
import 'package:tisini/features/events/presentation/controllers/ticket_controller.dart';

class TicketBinding extends Bindings {
  @override
  void dependencies() {
    // Data layer
    Get.lazyPut<TicketRemoteSource>(() => TicketRemoteSourceImpl());
    Get.lazyPut<TicketRepository>(
      () => TicketRepositoryImpl(remoteSource: Get.find()),
    );

    // Domain layer
    Get.lazyPut(() => CreateTicketUsecase(repository: Get.find()));

    // Presentation layer
    Get.lazyPut(() => TicketController(createTicketUsecase: Get.find()));
  }
}
