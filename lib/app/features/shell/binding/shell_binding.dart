import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/repositories/hydration_repository.dart';
import 'package:infinity_wellness/app/data/repositories/synergy_repository.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/mini_app_store/controller/mini_app_store_controller.dart';
import 'package:infinity_wellness/app/features/profile/controller/profile_controller.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';
import 'package:infinity_wellness/app/features/wallet/binding/wallet_binding.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<UserRepository>(() => UserRepositoryImpl(), fenix: true);
    Get.lazyPut<HydrationRepository>(() => HydrationRepositoryImpl(), fenix: true);
    Get.lazyPut<SynergyRepository>(() => SynergyRepositoryImpl(), fenix: true);

    // Controllers
    Get.lazyPut<ShellController>(() => ShellController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<FeedController>(() => FeedController(), fenix: true);
    Get.lazyPut<MiniAppStoreController>(() => MiniAppStoreController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);

    // Register all Wallet services, SDK, and WalletController
    WalletBinding().dependencies();
  }
}
