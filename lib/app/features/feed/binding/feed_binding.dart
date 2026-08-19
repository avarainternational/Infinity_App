import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedController>(() => FeedController(), fenix: true);
  }
}
