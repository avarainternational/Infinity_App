import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/auth/controller/onboarding_setup_controller.dart';

class OnboardingSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingSetupController>(
      () => OnboardingSetupController(),
    );
  }
}
