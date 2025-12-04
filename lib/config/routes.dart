import 'package:comic_book_reader/screens/homepage.dart';
import 'package:comic_book_reader/screens/library_page.dart';
import 'package:get/get.dart';
 
class AppRoutes {
  static final routes = [
    GetPage(
      name: '/',
      page: () => const HomePage(),
    ),
        GetPage(
      name: '/library',
      page: () => const LibraryPage(),
    ),
  ];
}
