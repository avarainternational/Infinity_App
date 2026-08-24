import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/hydration/controller/hydration_detail_controller.dart';

class HydrationDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HydrationDetailController>(() => HydrationDetailController());
  }
}
