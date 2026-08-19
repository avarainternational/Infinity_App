import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_builder_studio/app/core/base/base_view.dart';
import 'package:the_builder_studio/app/features/feed/screen/feed_screen.dart';
import 'package:the_builder_studio/app/features/home/screen/home_screen.dart';
import 'package:the_builder_studio/app/features/mini_app_store/screen/mini_app_store_screen.dart';
import 'package:the_builder_studio/app/features/profile/screen/profile_screen.dart';
import 'package:the_builder_studio/app/features/shell/controller/shell_controller.dart';
import 'package:the_builder_studio/app/features/wallet/screen/wallet_screen.dart';

class ShellScreen extends BaseView<ShellController> {
  const ShellScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeScreen(),
              FeedScreen(),
              MiniAppStoreScreen(),
              WalletScreen(),
              ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              selectedIcon: Icon(Icons.newspaper_rounded),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Mini-Apps',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Wallet',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}
