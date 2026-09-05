import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/splash/controller/splash_banner_controller.dart';

class SplashBannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashBannerController>(() => SplashBannerController());
  }
}
