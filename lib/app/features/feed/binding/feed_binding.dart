import 'package:get/get.dart';
import 'package:the_builder_studio/app/features/feed/controller/feed_controller.dart';

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedController>(() => FeedController(), fenix: true);
  }
}
