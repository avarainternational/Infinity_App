import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_string.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/wallet/controller/wallet_controller.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';
import 'package:infinity_wellness/app/widget/section_card.dart';

class WalletSendScreen extends BaseView<WalletController> {
  const WalletSendScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: WalletColors.background,
      appBar: AppBar(
        title: const Text(
          AppString.walletSendTitle,
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
        child: Obx(() {
          final isActivated = controller.walletAccess.value != null;
          if (!isActivated) {
            return const _MessagePanel(
              message: AppString.walletActivateFirstMessage,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(WalletSpacing.lg),
            children: [
              SectionCard(
                title: AppString.walletSendTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller.recipientController,
                      readOnly: true,
                      style: WalletTextStyles.mono,
                      decoration: InputDecoration(
                        labelText: AppString.walletRecipientLabel,
                        labelStyle: const TextStyle(color: WalletColors.textMuted),
                        hintText: AppString.walletRecipientReadonlyHint,
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: WalletColors.primary,
                        ),
                        filled: true,
                        fillColor: WalletColors.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WalletRadius.md),
                          borderSide: const BorderSide(color: WalletColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WalletRadius.md),
                          borderSide: const BorderSide(color: WalletColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WalletRadius.md),
                          borderSide: const BorderSide(color: WalletColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: WalletSpacing.md),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppString.walletAssetReadonlyLabel,
                        labelStyle: const TextStyle(color: WalletColors.textMuted),
                        prefixIcon: const Icon(
                          Icons.stars_rounded,
                          color: WalletColors.primary,
                        ),
                        filled: true,
                        fillColor: WalletColors.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WalletRadius.md),
                          borderSide: const BorderSide(color: WalletColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WalletRadius.md),
                          borderSide: const BorderSide(color: WalletColors.border),
                        ),
                      ),
                      child: Text(
                        controller.assetCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: WalletColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: WalletSpacing.md),
                    TextField(
                      controller: controller.amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: WalletColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: AppString.walletAmountLabel,
                        labelStyle: const TextStyle(color: WalletColors.textMuted),
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                          color: WalletColors.primary,
                        ),
                        filled: true,
                        fillColor: WalletColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WalletRadius.md),
                          borderSide: const BorderSide(color: WalletColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WalletRadius.md),
                          borderSide: const BorderSide(color: WalletColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(WalletRadius.md),
                          borderSide: const BorderSide(color: WalletColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: WalletSpacing.md),
                    _ValidationStatus(controller: controller),
                    const SizedBox(height: WalletSpacing.lg),
                    _ReviewButton(controller: controller),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ValidationStatus extends StatelessWidget {
  const _ValidationStatus({required this.controller});

  final WalletController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final message = controller.recipientValidationMessage.value;
      if (message.isEmpty) {
        return const SizedBox.shrink();
      }

      final isValid = controller.isRecipientValid.value;
      final isValidating = controller.isRecipientValidating.value;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: WalletSpacing.md,
          vertical: WalletSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isValidating
              ? WalletColors.infoBg
              : isValid
                  ? WalletColors.successBg
                  : WalletColors.errorBg,
          borderRadius: BorderRadius.circular(WalletRadius.sm),
          border: Border.all(
            color: isValidating
                ? WalletColors.infoBorder
                : isValid
                    ? WalletColors.successBorder
                    : WalletColors.errorBorder,
          ),
        ),
        child: Row(
          children: [
            if (isValidating)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(WalletColors.primary),
                ),
              )
            else
              Icon(
                isValid
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                size: 18,
                color: isValid ? WalletColors.success : WalletColors.error,
              ),
            const SizedBox(width: WalletSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isValidating
                      ? WalletColors.info
                      : isValid
                          ? WalletColors.success
                          : WalletColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ReviewButton extends StatelessWidget {
  const _ReviewButton({required this.controller});

  final WalletController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.amountController,
      builder: (_, value, _) {
        final amount = double.tryParse(value.text.trim());
        final hasValidAmount = amount != null && amount > 0;

        return Obx(
          () => SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: controller.isRecipientValid.value && hasValidAmount
                  ? controller.continueToReview
                  : null,
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text(
                AppString.walletReviewTitle,
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
        );
      },
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(WalletSpacing.lg),
      children: [
        SectionCard(
          title: AppString.walletSendTitle,
          child: Text(
            message,
            style: WalletTextStyles.bodyMuted,
          ),
        ),
      ],
    );
  }
}
