import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';

class ShellController extends BaseController {
  // Default to Home (index 2 in Wallet, Social, Home, Mini Apps, Profile)
  final currentIndex = 2.obs;

  void selectTab(int index) {
    currentIndex.value = index;
  }
}
