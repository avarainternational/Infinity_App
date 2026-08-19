import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/mini_app_store/controller/mini_app_store_controller.dart';

class MiniAppStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MiniAppStoreController>(() => MiniAppStoreController(), fenix: true);
  }
}
