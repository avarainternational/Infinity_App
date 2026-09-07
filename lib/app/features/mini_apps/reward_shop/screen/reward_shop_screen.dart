import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/mini_apps/reward_shop/controller/reward_shop_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RewardShopScreen extends BaseView<RewardShopController> {
  const RewardShopScreen({super.key});

  @override
  Widget buildView(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(title: const Text('Reward Shop')),
    body: SafeArea(
      child: Obx(() {
        final ready = controller.ready.value;
        if (!controller.supported) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Open Reward Shop in the Android or iOS app. For a browser preview, run npm run dev in the mini-app folder.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.error.value, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.load,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        // Read ready even while the controller is being initialized so Obx
        // rebuilds when the asset has finished loading.
        final view = controller.webView;
        return Stack(
          children: [
            if (view != null) WebViewWidget(controller: view),
            if (!ready) const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    ),
  );
}
