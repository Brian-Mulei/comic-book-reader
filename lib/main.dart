import 'package:comic_book_reader/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/app_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        initialBinding: AppBindings(),
      initialRoute: '/library',
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}