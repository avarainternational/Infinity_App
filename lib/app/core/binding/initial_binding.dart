import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/data/services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationService>()) {
      Get.put<NotificationService>(NotificationService(), permanent: true);
    }
    Get.put<AuthService>(AuthService(), permanent: true);
  }
}
