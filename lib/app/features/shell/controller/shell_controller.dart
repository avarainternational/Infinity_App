import 'package:get/get.dart';
import 'package:the_builder_studio/app/core/base/base_controller.dart';

class ShellController extends BaseController {
  final currentIndex = 0.obs;

  void selectTab(int index) {
    currentIndex.value = index;
  }
}
