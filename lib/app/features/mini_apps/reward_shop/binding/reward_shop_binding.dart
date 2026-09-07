import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/mini_apps/reward_shop/controller/reward_shop_controller.dart';

class RewardShopBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(RewardShopController.new);
}
