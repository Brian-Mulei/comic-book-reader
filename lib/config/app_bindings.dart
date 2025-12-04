 
import 'package:get/get.dart';
import '../controllers/comic_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ComicController());  // async init happens inside controller
  }
}
