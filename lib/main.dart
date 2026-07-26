import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tisini/app.dart';
import 'package:tisini/core/auth/session_service.dart';
import 'package:tisini/core/services/auth_token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await AuthTokenStorage.initialize();

  if (!Get.isRegistered<SessionService>()) {
    Get.put(SessionService(), permanent: true);
  }

  runApp(const MyApp());
}
