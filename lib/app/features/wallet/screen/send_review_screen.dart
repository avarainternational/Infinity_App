import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_string.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/wallet/controller/wallet_controller.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';
import 'package:infinity_wellness/app/widget/section_card.dart';

class WalletSendReviewScreen extends BaseView<WalletController> {
  const WalletSendReviewScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: WalletColors.background,
      appBar: AppBar(
        title: const Text(
          AppString.walletReviewTitle,
          style: TextStyle(
            color: WalletColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: WalletColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: WalletColors.border),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.all(WalletSpacing.lg),
            children: [
              SectionCard(
                title: AppString.walletReviewTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ReviewRow(
                      label: AppString.walletRecipientLabel,
                      value: controller.recipientController.text,
                      isMono: true,
                    ),
                    _ReviewRow(
                      label: AppString.walletAmountLabel,
                      value: '${controller.amountController.text} ${controller.assetCode}',
                      isBold: true,
                    ),
                    _ReviewRow(
                      label: AppString.walletAssetCodeLabel,
                      value: controller.assetCode,
                    ),
                    _ReviewRow(
                      label: AppString.walletNetworkLabel,
                      value: controller.networkName,
                    ),
                    const SizedBox(height: WalletSpacing.md),
                    if (!controller.isWalletUnlocked) ...[
                      SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: controller.unlockWalletForSend,
                          icon: const Icon(Icons.lock_open_rounded, size: 18),
                          label: const Text(
                            AppString.walletUnlockButton,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: WalletColors.primary,
                            side: const BorderSide(color: WalletColors.border, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(WalletRadius.md),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: WalletSpacing.md),
                    ],
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: controller.isSubmittingSend.value
                            ? null
                            : controller.confirmSend,
                        icon: controller.isSubmittingSend.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    WalletColors.textOnPrimary,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          AppString.walletConfirmSend,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: WalletColors.primary,
                          disabledBackgroundColor: WalletColors.surfaceMuted,
                          foregroundColor: WalletColors.textOnPrimary,
                          disabledForegroundColor: WalletColors.textLight,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(WalletRadius.md),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.isMono = false,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isMono;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WalletSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: WalletColors.textMuted,
            ),
          ),
          const SizedBox(height: WalletSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: WalletSpacing.md,
              vertical: WalletSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: WalletColors.surfaceMuted,
              borderRadius: BorderRadius.circular(WalletRadius.sm),
              border: Border.all(color: WalletColors.border),
            ),
            child: SelectableText(
              value.isEmpty ? AppString.walletUnavailableValue : value,
              style: TextStyle(
                fontFamily: isMono ? 'monospace' : null,
                fontSize: isBold ? 15 : 13,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: isBold ? WalletColors.primary : WalletColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
