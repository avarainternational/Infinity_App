import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/features/feed/binding/feed_binding.dart';
import 'package:infinity_wellness/app/features/feed/screen/feed_screen.dart';
import 'package:infinity_wellness/app/features/home/binding/home_binding.dart';
import 'package:infinity_wellness/app/features/home/screen/home_screen.dart';
import 'package:infinity_wellness/app/features/mini_app_store/binding/mini_app_store_binding.dart';
import 'package:infinity_wellness/app/features/mini_app_store/screen/mini_app_store_screen.dart';
import 'package:infinity_wellness/app/features/profile/binding/profile_binding.dart';
import 'package:infinity_wellness/app/features/profile/screen/profile_screen.dart';
import 'package:infinity_wellness/app/features/shell/binding/shell_binding.dart';
import 'package:infinity_wellness/app/features/shell/screen/shell_screen.dart';
import 'package:infinity_wellness/app/features/wallet/binding/wallet_binding.dart';
import 'package:infinity_wellness/app/features/wallet/screen/receive_screen.dart';
import 'package:infinity_wellness/app/features/wallet/screen/send_review_screen.dart';
import 'package:infinity_wellness/app/features/wallet/screen/send_scan_screen.dart';
import 'package:infinity_wellness/app/features/wallet/screen/send_screen.dart';
import 'package:infinity_wellness/app/features/wallet/screen/transaction_history_screen.dart';
import 'package:infinity_wellness/app/features/wallet/screen/wallet_screen.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.shell;

  static final routes = [
    GetPage(
      name: Routes.shell,
      page: () => const ShellScreen(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.feed,
      page: () => const FeedScreen(),
      binding: FeedBinding(),
    ),
    GetPage(
      name: Routes.miniAppStore,
      page: () => const MiniAppStoreScreen(),
      binding: MiniAppStoreBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    // Compatibility alias
    GetPage(
      name: Routes.profileScreen,
      page: () => const ShellScreen(),
      binding: ShellBinding(),
    ),
    // Wallet Routes (Retained)
    GetPage(
      name: Routes.wallet,
      page: () => const WalletScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.walletReceive,
      page: () => const WalletReceiveScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.walletSend,
      page: () => const WalletSendScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.walletSendScan,
      page: () => const WalletSendScanScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.walletSendReview,
      page: () => const WalletSendReviewScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.walletHistory,
      page: () => const WalletTransactionHistoryScreen(),
      binding: WalletBinding(),
    ),
  ];
}
