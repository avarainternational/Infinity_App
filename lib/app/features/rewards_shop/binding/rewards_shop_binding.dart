import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/rewards_shop/controller/rewards_shop_controller.dart';

class RewardsShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RewardsShopController>(() => RewardsShopController());
  }
}
