import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/achievements/controller/achievements_controller.dart';

class AchievementsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AchievementsController>(() => AchievementsController());
  }
}
