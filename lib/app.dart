import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/routes/routes.dart';
import 'package:tisini/core/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tisini',
      debugShowCheckedModeBanner: false,
      // themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      // darkTheme: TAppTheme.darkTheme,
      initialRoute: "/splash",
      getPages: AppPages.route,
    );
  }
}
