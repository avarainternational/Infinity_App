import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.ambientGradientColors,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
        children: [
          // 1. Top Header: Title, Wallet Icon, Menu Action
          _buildTopHeader(context),
          const SizedBox(height: 16),

          // 2. Main Balance Card
          _buildBalanceCard(context),
          const SizedBox(height: 16),

          // 3. Small Shop Portal (In place of banner)
          _buildShopPortal(context),
          const SizedBox(height: 16),

          // 4. Transfer & Receive Hub Card
          _buildTransferHubCard(context),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header: Title & Action
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.mintSoft,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 28,
                    color: AppColors.primaryVibrant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ecosystem Wallet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Wellness Points & streak perks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSubtitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showWalletMenu(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.cyanPillBorder.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.more_horiz_rounded,
                size: 26,
                color: AppColors.textMuted,
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
          padding: const EdgeInsets.all(WalletSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyanBadgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history_rounded, color: AppColors.primary),
                ),
                title: const Text(
                  AppString.walletHistoryTitle,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: const Text('View your points transactions'),
                onTap: () {
                  Get.back<void>();
                  controller.openHistory();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyanBadgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                ),
                title: const Text(
                  AppString.walletReceiveTitle,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: const Text('Show QR code to receive points'),
                onTap: () {
                  Get.back<void>();
                  controller.openReceive();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyanBadgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                ),
                title: const Text(
                  AppString.walletSendTitle,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: const Text('Scan QR code to transfer points'),
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
  // Main Balance Card
  // ---------------------------------------------------------------------------
  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.cyanBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Wellness Points',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: controller.refreshWalletBalance,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.cyanPillBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.cyanPillBorder,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final formattedBalance =
                double.tryParse(controller.currentBalance.value)?.toStringAsFixed(0) ??
                controller.currentBalance.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedBalance,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'pts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDarkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Earned from daily hydration & synergy streaks',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSlate,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.streakOrangeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 16, color: AppColors.streakOrange),
                    SizedBox(width: 4),
                    Text(
                      '+50 Daily Streak Active',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.streakOrangeDeep,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: controller.openHistory,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cyanPillBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.cyanPillBorder,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'view history',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSubtitle,
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
  // ---------------------------------------------------------------------------
  // Small Shop Portal Card (Connecting to Full Rewards Shop Mini-App)
  // ---------------------------------------------------------------------------
  Widget _buildShopPortal(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.rewardsShop),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0099FF),
              Color(0xFF0066CC),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077BE).withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Icon Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.storefront_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),

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
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '✨',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Redeem points for bottles, drops & perks',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD6F2FE),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right CTA Capsule
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shop',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.primaryDarkBlue,
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
  // Transfer & Receive Hub Card
  // ---------------------------------------------------------------------------
  Widget _buildTransferHubCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.cyanBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Transfer & Receive',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Mode Toggle (Receive / Send)
          _buildModeToggle(),
          const SizedBox(height: 16),

          // Body Content
          Obx(() {
            switch (controller.walletState.value) {
              case WalletState.loading:
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              case WalletState.configMissing:
              case WalletState.error:
                return _buildErrorState();
              case WalletState.ready:
                return _buildActivationPanel();
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

  Widget _buildModeToggle() {
    return Obx(() {
      final active = controller.rewardsMode.value;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cyanToggleBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.rewardsMode.value = 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active == 0 ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: active == 0
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 18,
                        color: active == 0
                            ? AppColors.primaryDarkBlue
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppString.walletReceiveTitle,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              active == 0 ? FontWeight.w800 : FontWeight.w600,
                          color: active == 0
                              ? AppColors.textDark
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.rewardsMode.value = 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active == 1 ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: active == 1
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: active == 1
                            ? AppColors.primaryDarkBlue
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppString.walletSendTitle,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              active == 1 ? FontWeight.w800 : FontWeight.w600,
                          color: active == 1
                              ? AppColors.textDark
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActivationPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.cyanPillBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_open_rounded,
            size: 32,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Activate Your Points Wallet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          AppString.walletReadyToActivateMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: controller.activateWallet,
            icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
            label: const Text(AppString.walletActivateButton),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryVibrant,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceivePanel(BuildContext context) {
    final access = controller.walletAccess.value;
    final publicKey = access?.publicKey ?? '';

    return Column(
      children: [
        Center(
          child: Container(
            width: 190,
            height: 190,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.iceBlueBgSoft,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cyanPillBorder, width: 1.5),
            ),
            child: publicKey.isEmpty
                ? const Icon(
                    Icons.qr_code_2_rounded,
                    size: 110,
                    color: AppColors.primaryVibrant,
                  )
                : QrImageView(
                    data: publicKey,
                    version: QrVersions.auto,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.primaryVibrant,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.primaryVibrant,
                    ),
                    backgroundColor: AppColors.iceBlueBgSoft,
                    gapless: false,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Show this QR code to receive points from friends',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSlate,
          ),
        ),
        const SizedBox(height: 14),

        // Reward ID with copy button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.iceBlueBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cyanBadgeBg),
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
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSlate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _shortRewardId(publicKey),
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: publicKey.isEmpty ? null : controller.copyPublicKey,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cyanPillBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyanPillBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 14, color: AppColors.primaryDarkBlue),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDarkBlue,
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

  Widget _buildSendPanel(BuildContext context) {
    return _InlineWalletScanner(controller: controller);
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        controller.message.value.isNotEmpty
            ? controller.message.value
            : 'Wallet configuration error. Please try again.',
        style: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
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
          if (tabIndex == 0) {
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
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.cyanPillBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDarkBlue.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
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
                          AppColors.primary,
                        ),
                      ),
                    ),
                    errorBuilder: (_, _) => _buildCameraFallback(),
                  ),

                  // Reticle and Scan Beam
                  CustomPaint(
                    painter: _ScannerReticlePainter(
                      scanProgress: _isRunning ? _scanAnimation.value : 0.5,
                      showScanLine: _isRunning,
                    ),
                  ),

                  // Torch Toggle Button (Top Right)
                  if (_isRunning)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: _toggleTorch,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isTorchOn
                                  ? AppColors.primary
                                  : Colors.white38,
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            _isTorchOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            size: 16,
                            color: _isTorchOn ? AppColors.primary : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Status Feedback
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isProcessing
                  ? Icons.hourglass_top_rounded
                  : Icons.qr_code_scanner_rounded,
              size: 15,
              color: AppColors.primaryDarkBlue,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSlate,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Bottom Action: Paste Copied ID
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.iceBlueBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cyanBadgeBg),
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
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSlate,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Paste from clipboard to send',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pasteFromClipboard,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyanPillBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyanPillBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.content_paste_rounded,
                        size: 14,
                        color: AppColors.primaryDarkBlue,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Paste',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDarkBlue,
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
              size: 38,
            ),
            const SizedBox(height: 8),
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
                    color: AppColors.primaryDarkBlue,
                    borderRadius: BorderRadius.circular(8),
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

class _ScannerReticlePainter extends CustomPainter {
  _ScannerReticlePainter({
    required this.scanProgress,
    required this.showScanLine,
  });

  final double scanProgress;
  final bool showScanLine;

  @override
  void paint(Canvas canvas, Size size) {
    const cornerLength = 22.0;
    const cornerRadius = 6.0;
    const padding = 18.0;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
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
            AppColors.primary.withValues(alpha: 0.0),
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.0),
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
  bool shouldRepaint(covariant _ScannerReticlePainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress ||
        oldDelegate.showScanLine != showScanLine;
  }
}
