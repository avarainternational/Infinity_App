import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:infinity_wellness/app/constant/resources/app_string.dart';
import 'package:infinity_wellness/app/constant/routing/app_route.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';
import 'package:infinity_wellness/app/features/wallet/controller/wallet_controller.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';

class WalletScreen extends BaseView<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Container(
      color: WalletColors.background,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            // 1. Top Header: Icon, Title, Subtitle, 3-dot Menu
            _buildTopHeader(context),
            const SizedBox(height: WalletSpacing.lg),

            // 2. Main Balance Card ("Wellness Points")
            _buildBalanceCard(context),
            const SizedBox(height: WalletSpacing.md),

            // 3. Rewards Shop Portal Card (Soft cyan tint)
            _buildShopPortal(context),
            const SizedBox(height: WalletSpacing.md),

            // 4. Transfer & Receive Hub Card (Segmented Control + Actions)
            _buildTransferHubCard(context),
            const SizedBox(height: WalletSpacing.md),

            // 5. Activation / Security Card (when not activated or for access info)
            _buildWalletStatusSection(context),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header: Title, Subtitle, Wallet Icon & Options Menu
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              // Wallet Icon Container with custom Shadcn blue styling
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: WalletColors.surface,
                  borderRadius: BorderRadius.circular(WalletRadius.md),
                  border: Border.all(
                    color: WalletColors.primaryBorder,
                    width: 1.2,
                  ),
                  boxShadow: WalletShadows.level1,
                ),
                child: const Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 26,
                        color: WalletColors.primary,
                      ),
                      Positioned(
                        right: 8,
                        bottom: 9,
                        child: Icon(
                          Icons.water_drop_rounded,
                          size: 10,
                          color: WalletColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: WalletSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ecosystem Wallet',
                      style: WalletTextStyles.heading2,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Wellness Points & streak perks',
                      style: WalletTextStyles.bodyMuted,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: WalletSpacing.sm),
        // 3-dot Menu Button
        GestureDetector(
          onTap: () => _showWalletMenu(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: WalletColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: WalletColors.border,
                width: 1,
              ),
              boxShadow: WalletShadows.level1,
            ),
            child: const Center(
              child: Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: WalletColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showWalletMenu(BuildContext context) {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: WalletSpacing.lg,
            vertical: WalletSpacing.md,
          ),
          decoration: const BoxDecoration(
            color: WalletColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(WalletRadius.xl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: WalletSpacing.md),
                decoration: BoxDecoration(
                  color: WalletColors.border,
                  borderRadius: BorderRadius.circular(WalletRadius.pill),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(WalletSpacing.sm),
                  decoration: BoxDecoration(
                    color: WalletColors.primaryLight,
                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: WalletColors.primary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  AppString.walletHistoryTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: WalletColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'View your points transactions',
                  style: TextStyle(
                    fontSize: 13,
                    color: WalletColors.textMuted,
                  ),
                ),
                onTap: () {
                  Get.back<void>();
                  controller.openHistory();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(WalletSpacing.sm),
                  decoration: BoxDecoration(
                    color: WalletColors.primaryLight,
                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: WalletColors.primary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  AppString.walletReceiveTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: WalletColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Show QR code to receive points',
                  style: TextStyle(
                    fontSize: 13,
                    color: WalletColors.textMuted,
                  ),
                ),
                onTap: () {
                  Get.back<void>();
                  controller.openReceive();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(WalletSpacing.sm),
                  decoration: BoxDecoration(
                    color: WalletColors.primaryLight,
                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: WalletColors.primary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  AppString.walletSendTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: WalletColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Scan QR code to transfer points',
                  style: TextStyle(
                    fontSize: 13,
                    color: WalletColors.textMuted,
                  ),
                ),
                onTap: () {
                  Get.back<void>();
                  controller.openSendScan();
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Main Balance Card ("Wellness Points")
  // ---------------------------------------------------------------------------
  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WalletSpacing.lg),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        border: Border.all(color: WalletColors.border, width: 1),
        boxShadow: WalletShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Star Icon + Title + Refresh Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_border_rounded,
                    color: WalletColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: WalletSpacing.sm),
                  const Text(
                    'Wellness Points',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: WalletColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: controller.refreshWalletBalance,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: WalletColors.surface,
                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                    border: Border.all(
                      color: WalletColors.border,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: WalletColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WalletSpacing.md),

          // Big Bold Blue Balance Display
          Obx(() {
            final rawBalance = controller.currentBalance.value;
            final numeric = double.tryParse(rawBalance);
            final formattedBalance = numeric != null
                ? numeric.toStringAsFixed(numeric.truncateToDouble() == numeric ? 0 : 2)
                : rawBalance;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedBalance,
                      style: WalletTextStyles.balanceDisplay,
                    ),
                    const SizedBox(width: WalletSpacing.xs + 2),
                    const Text(
                      'pts',
                      style: WalletTextStyles.balanceUnit,
                    ),
                  ],
                ),
                const SizedBox(height: WalletSpacing.xxs),
                const Text(
                  'Earned from daily hydration & synergy streaks',
                  style: WalletTextStyles.bodyMuted,
                ),
              ],
            );
          }),
          const SizedBox(height: WalletSpacing.md),
          const Divider(height: 1, thickness: 1, color: WalletColors.divider),
          const SizedBox(height: WalletSpacing.md),

          // Bottom Action & Streak Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // +50 Daily Streak Active Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: WalletSpacing.sm + 2,
                  vertical: WalletSpacing.xs + 1,
                ),
                decoration: BoxDecoration(
                  color: WalletColors.successBg,
                  borderRadius: BorderRadius.circular(WalletRadius.xs),
                  border: Border.all(
                    color: WalletColors.successBorder,
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 15,
                      color: WalletColors.success,
                    ),
                    SizedBox(width: WalletSpacing.xs),
                    Text(
                      '+50 Daily Streak Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: WalletColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              // View History Outlined Button
              GestureDetector(
                onTap: controller.openHistory,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WalletSpacing.md,
                    vertical: WalletSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: WalletColors.surface,
                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                    border: Border.all(
                      color: WalletColors.border,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'View History',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: WalletColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Small Shop Portal Card (Soft cyan tint matching Shadcn mockup)
  // ---------------------------------------------------------------------------
  Widget _buildShopPortal(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.rewardsShop),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: WalletSpacing.lg,
          vertical: WalletSpacing.md + 2,
        ),
        decoration: BoxDecoration(
          color: WalletColors.shopBg,
          borderRadius: BorderRadius.circular(WalletRadius.xl),
          border: Border.all(
            color: WalletColors.shopBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Left Store Icon
            const Icon(
              Icons.storefront_outlined,
              size: 28,
              color: WalletColors.shopIcon,
            ),
            const SizedBox(width: WalletSpacing.md),

            // Middle Texts
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Rewards Shop',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: WalletColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text('✨', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Redeem points for bottles, ...',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: WalletColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: WalletSpacing.sm),

            // Right CTA Outlined Button ("Shop →")
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: WalletSpacing.md,
                vertical: WalletSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: WalletColors.surface,
                borderRadius: BorderRadius.circular(WalletRadius.sm),
                border: Border.all(
                  color: WalletColors.shopIcon,
                  width: 1.2,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shop',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: WalletColors.shopText,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: WalletColors.shopText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Transfer & Receive Hub Card (Segmented Control & Inline Actions)
  // ---------------------------------------------------------------------------
  Widget _buildTransferHubCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WalletSpacing.lg),
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.xl),
        border: Border.all(color: WalletColors.border, width: 1),
        boxShadow: WalletShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          const Row(
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                color: WalletColors.primary,
                size: 22,
              ),
              SizedBox(width: WalletSpacing.sm),
              Text(
                'Transfer & Receive',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: WalletColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: WalletSpacing.md),

          // Shadcn Segmented Control Tabs (Receive / Send)
          _buildSegmentedTabs(),
          const SizedBox(height: WalletSpacing.md),

          // Body Content depending on wallet state & selected tab
          Obx(() {
            switch (controller.walletState.value) {
              case WalletState.loading:
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(WalletSpacing.xl),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(WalletColors.primary),
                    ),
                  ),
                );
              case WalletState.configMissing:
              case WalletState.error:
                return _buildErrorState();
              case WalletState.ready:
              case WalletState.activated:
                return controller.rewardsMode.value == 0
                    ? _buildReceivePanel(context)
                    : _buildSendPanel(context);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Obx(() {
      final activeIndex = controller.rewardsMode.value;

      return Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: WalletColors.tabBg,
          borderRadius: BorderRadius.circular(WalletRadius.md),
        ),
        child: Row(
          children: [
            // Receive Tab
            Expanded(
              child: GestureDetector(
                onTap: () => controller.rewardsMode.value = 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: activeIndex == 0
                        ? WalletColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                    boxShadow: activeIndex == 0 ? WalletShadows.level1 : null,
                  ),
                  child: Center(
                    child: Text(
                      AppString.walletReceiveTitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: activeIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: activeIndex == 0
                            ? WalletColors.textOnPrimary
                            : WalletColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Send Tab
            Expanded(
              child: GestureDetector(
                onTap: () => controller.rewardsMode.value = 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: activeIndex == 1
                        ? WalletColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                    boxShadow: activeIndex == 1 ? WalletShadows.level1 : null,
                  ),
                  child: Center(
                    child: Text(
                      AppString.walletSendTitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: activeIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: activeIndex == 1
                            ? WalletColors.textOnPrimary
                            : WalletColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Receive Panel with QR Code and Reward ID Copy Card
  // ---------------------------------------------------------------------------
  Widget _buildReceivePanel(BuildContext context) {
    final access = controller.walletAccess.value;
    final publicKey = access?.publicKey ?? '';

    return Column(
      children: [
        // Dual Quick Action Cards (Receive / Send overview)
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: WalletColors.surface,
                  borderRadius: BorderRadius.circular(WalletRadius.md),
                  border: Border.all(
                    color: WalletColors.border,
                    width: 1,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 28,
                      color: WalletColors.primary,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Receive',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: WalletColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: WalletSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.rewardsMode.value = 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: WalletColors.surface,
                    borderRadius: BorderRadius.circular(WalletRadius.md),
                    border: Border.all(
                      color: WalletColors.border,
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.send_rounded,
                        size: 28,
                        color: WalletColors.primary,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: WalletColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: WalletSpacing.lg),

        // QR Container
        Center(
          child: Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(WalletSpacing.md),
            decoration: BoxDecoration(
              color: WalletColors.surface,
              borderRadius: BorderRadius.circular(WalletRadius.lg),
              border: Border.all(color: WalletColors.border, width: 1.5),
              boxShadow: WalletShadows.level1,
            ),
            child: publicKey.isEmpty
                ? const Icon(
                    Icons.qr_code_2_rounded,
                    size: 100,
                    color: WalletColors.primary,
                  )
                : QrImageView(
                    data: publicKey,
                    version: QrVersions.auto,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: WalletColors.primary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: WalletColors.primary,
                    ),
                    backgroundColor: WalletColors.surface,
                    gapless: false,
                  ),
          ),
        ),
        const SizedBox(height: WalletSpacing.md),
        const Text(
          'Show this QR code to receive points from friends',
          textAlign: TextAlign.center,
          style: WalletTextStyles.bodyMuted,
        ),
        const SizedBox(height: WalletSpacing.md),

        // Your Reward ID & Copy Button
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: WalletSpacing.md,
            vertical: WalletSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: WalletColors.surfaceMuted,
            borderRadius: BorderRadius.circular(WalletRadius.md),
            border: Border.all(color: WalletColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Reward ID',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WalletColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _shortRewardId(publicKey),
                      style: WalletTextStyles.mono,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: publicKey.isEmpty ? null : controller.copyPublicKey,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WalletSpacing.md,
                    vertical: WalletSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: WalletColors.primaryLight,
                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                    border: Border.all(color: WalletColors.primaryBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: WalletColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: WalletColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Send Panel with Inline Live Camera QR Scanner
  // ---------------------------------------------------------------------------
  Widget _buildSendPanel(BuildContext context) {
    return _InlineWalletScanner(controller: controller);
  }

  // ---------------------------------------------------------------------------
  // Standalone Activation / Security Section
  // ---------------------------------------------------------------------------
  Widget _buildWalletStatusSection(BuildContext context) {
    return Obx(() {
      final isActivated = controller.walletState.value == WalletState.activated;

      if (isActivated) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(WalletSpacing.lg),
        decoration: BoxDecoration(
          color: WalletColors.surface,
          borderRadius: BorderRadius.circular(WalletRadius.xl),
          border: Border.all(color: WalletColors.border, width: 1),
          boxShadow: WalletShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: WalletColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: WalletColors.primaryBorder),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: WalletColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: WalletSpacing.md),
                const Expanded(
                  child: Text(
                    'Activate Your Points Wallet',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: WalletColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: WalletSpacing.sm),
            const Text(
              'Activate your wallet by selecting your customer access ZIP file from this phone.',
              style: WalletTextStyles.bodyMuted,
            ),
            const SizedBox(height: WalletSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: controller.activateWallet,
                icon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: WalletColors.textOnPrimary,
                ),
                label: const Text(
                  AppString.walletActivateButton,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: WalletColors.textOnPrimary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: WalletColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(WalletRadius.md),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(WalletSpacing.md),
      decoration: BoxDecoration(
        color: WalletColors.errorBg,
        borderRadius: BorderRadius.circular(WalletRadius.md),
        border: Border.all(color: WalletColors.errorBorder),
      ),
      child: Text(
        controller.message.value.isNotEmpty
            ? controller.message.value
            : 'Wallet configuration error. Please try again.',
        style: const TextStyle(
          color: WalletColors.error,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  String _shortRewardId(String value) {
    if (value.isEmpty) {
      return 'Activate wallet first';
    }
    if (value.length <= 14) {
      return value;
    }
    return '${value.substring(0, 7)}...${value.substring(value.length - 6)}';
  }
}

// =============================================================================
// Live Inline QR Scanner with Shadcn Styled Reticle & Helpers
// =============================================================================
class _InlineWalletScanner extends StatefulWidget {
  const _InlineWalletScanner({required this.controller});

  final WalletController controller;

  @override
  State<_InlineWalletScanner> createState() => _InlineWalletScannerState();
}

class _InlineWalletScannerState extends State<_InlineWalletScanner>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 700,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );

  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  String _status = 'Point camera at friend\'s QR code';
  bool _isRunning = false;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isPermissionDenied = false;
  StreamSubscription<BarcodeCapture>? _barcodeSubscription;
  Worker? _shellTabWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.12, end: 0.88).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (Get.isRegistered<ShellController>()) {
      _shellTabWorker = ever(
        Get.find<ShellController>().currentIndex,
        (tabIndex) {
          if (tabIndex == 3) {
            unawaited(_startScanner());
          } else {
            unawaited(_stopScanner());
          }
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startScanner());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_startScanner());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_stopScanner());
        break;
    }
  }

  Future<void> _startScanner() async {
    if (!mounted || _isRunning) {
      return;
    }

    _barcodeSubscription ??= _scannerController.barcodes.listen(
      _handleDetection,
    );

    try {
      await _scannerController.start();
      if (!mounted) return;
      setState(() {
        _isRunning = true;
        _isPermissionDenied = false;
        _status = 'Scanning for recipient QR code...';
      });
    } on MobileScannerException catch (error) {
      await _barcodeSubscription?.cancel();
      _barcodeSubscription = null;
      if (!mounted) return;
      setState(() {
        _isRunning = false;
        _isPermissionDenied =
            error.errorCode == MobileScannerErrorCode.permissionDenied;
        _status = _isPermissionDenied
            ? 'Camera permission denied. Enable camera access.'
            : 'Camera unavailable on this device.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRunning = false;
        _status = 'Camera unavailable';
      });
    }
  }

  Future<void> _stopScanner() async {
    _isRunning = false;
    await _barcodeSubscription?.cancel();
    _barcodeSubscription = null;
    try {
      await _scannerController.stop();
    } catch (_) {
      // Camera shutdown can fail during lifecycle transitions.
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
      if (mounted) {
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;
    final rawValue = capture.barcodes
        .map((b) => b.rawValue?.trim() ?? '')
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');

    final normalized = widget.controller.normalizeWalletPublicKey(rawValue);

    if (normalized == null) {
      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() => _status = AppString.walletInvalidQr);
      }
      await Future<void>.delayed(const Duration(milliseconds: 1600));
      if (mounted) {
        setState(() => _status = 'Point camera at friend\'s QR code');
      }
      _isProcessing = false;
      return;
    }

    HapticFeedback.selectionClick();
    if (mounted) {
      setState(() => _status = 'Recipient detected! Opening send form...');
    }
    await _stopScanner();
    await widget.controller.applyScannedRecipient(normalized);
    if (mounted) {
      _isProcessing = false;
      unawaited(_startScanner());
    }
  }

  Future<void> _pasteFromClipboard() async {
    await widget.controller.pasteRecipientFromClipboard();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera Viewfinder Box
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(WalletRadius.lg),
              border: Border.all(
                color: WalletColors.primaryBorder,
                width: 1.5,
              ),
              boxShadow: WalletShadows.level2,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(WalletRadius.lg - 2),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    fit: BoxFit.cover,
                    useAppLifecycleState: false,
                    placeholderBuilder: (_) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          WalletColors.primary,
                        ),
                      ),
                    ),
                    errorBuilder: (_, _) => _buildCameraFallback(),
                  ),

                  // Reticle and Scan Beam
                  CustomPaint(
                    painter: _ShadcnScannerReticlePainter(
                      scanProgress: _isRunning ? _scanAnimation.value : 0.5,
                      showScanLine: _isRunning,
                    ),
                  ),

                  // Torch Toggle Button
                  if (_isRunning)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _toggleTorch,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isTorchOn
                                  ? WalletColors.primary
                                  : Colors.white38,
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            _isTorchOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            size: 15,
                            color: _isTorchOn ? WalletColors.primary : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: WalletSpacing.md),

        // Status Feedback
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isProcessing
                  ? Icons.hourglass_top_rounded
                  : Icons.qr_code_scanner_rounded,
              size: 15,
              color: WalletColors.primary,
            ),
            const SizedBox(width: WalletSpacing.xs),
            Flexible(
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: WalletTextStyles.bodyMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: WalletSpacing.md),

        // Bottom Action: Paste Copied ID
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: WalletSpacing.md,
            vertical: WalletSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: WalletColors.surfaceMuted,
            borderRadius: BorderRadius.circular(WalletRadius.md),
            border: Border.all(color: WalletColors.border),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Have a Copied ID?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WalletColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Paste from clipboard to send',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: WalletColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pasteFromClipboard,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: WalletSpacing.md,
                    vertical: WalletSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: WalletColors.primaryLight,
                    borderRadius: BorderRadius.circular(WalletRadius.sm),
                    border: Border.all(color: WalletColors.primaryBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.content_paste_rounded,
                        size: 13,
                        color: WalletColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Paste',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: WalletColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraFallback() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white54,
              size: 36,
            ),
            const SizedBox(height: 6),
            Text(
              _isPermissionDenied ? 'Permission Denied' : 'Camera Preview',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!_isRunning) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => unawaited(_startScanner()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: WalletColors.primary,
                    borderRadius: BorderRadius.circular(WalletRadius.xs),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shellTabWorker?.dispose();
    _animController.dispose();
    unawaited(_barcodeSubscription?.cancel());
    unawaited(_scannerController.dispose());
    super.dispose();
  }
}

class _ShadcnScannerReticlePainter extends CustomPainter {
  _ShadcnScannerReticlePainter({
    required this.scanProgress,
    required this.showScanLine,
  });

  final double scanProgress;
  final bool showScanLine;

  @override
  void paint(Canvas canvas, Size size) {
    const cornerLength = 20.0;
    const cornerRadius = 6.0;
    const padding = 16.0;

    final paint = Paint()
      ..color = WalletColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final left = padding;
    final top = padding;
    final right = size.width - padding;
    final bottom = size.height - padding;

    // Top-Left Corner
    final tlPath = Path()
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top + cornerRadius)
      ..arcToPoint(
        Offset(left + cornerRadius, top),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(left + cornerLength, top);
    canvas.drawPath(tlPath, paint);

    // Top-Right Corner
    final trPath = Path()
      ..moveTo(right - cornerLength, top)
      ..lineTo(right - cornerRadius, top)
      ..arcToPoint(
        Offset(right, top + cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(right, top + cornerLength);
    canvas.drawPath(trPath, paint);

    // Bottom-Left Corner
    final blPath = Path()
      ..moveTo(left, bottom - cornerLength)
      ..lineTo(left, bottom - cornerRadius)
      ..arcToPoint(
        Offset(left + cornerRadius, bottom),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(left + cornerLength, bottom);
    canvas.drawPath(blPath, paint);

    // Bottom-Right Corner
    final brPath = Path()
      ..moveTo(right - cornerLength, bottom)
      ..lineTo(right - cornerRadius, bottom)
      ..arcToPoint(
        Offset(right, bottom - cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(right, bottom - cornerLength);
    canvas.drawPath(brPath, paint);

    // Animated Scan Line
    if (showScanLine) {
      final scanY = top + (bottom - top) * scanProgress;
      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            WalletColors.primary.withValues(alpha: 0.0),
            WalletColors.primary,
            WalletColors.primary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(left, scanY, right - left, 2))
        ..strokeWidth = 2.0;

      canvas.drawLine(
        Offset(left + 8, scanY),
        Offset(right - 8, scanY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShadcnScannerReticlePainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress ||
        oldDelegate.showScanLine != showScanLine;
  }
}
