import 'package:get/get.dart';
import 'package:the_builder_studio/app/features/home/controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
