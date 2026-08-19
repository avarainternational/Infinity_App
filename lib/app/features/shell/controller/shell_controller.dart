import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';

class ShellController extends BaseController {
  final currentIndex = 0.obs;

  void selectTab(int index) {
    currentIndex.value = index;
  }
}
