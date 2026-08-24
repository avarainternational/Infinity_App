import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
  }
}
