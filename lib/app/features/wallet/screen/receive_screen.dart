import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_string.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/wallet/controller/wallet_controller.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';
import 'package:infinity_wellness/app/widget/section_card.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletReceiveScreen extends BaseView<WalletController> {
  const WalletReceiveScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: WalletColors.background,
      appBar: AppBar(
        title: const Text(
          AppString.walletReceiveTitle,
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
          final access = controller.walletAccess.value;

          return ListView(
            padding: const EdgeInsets.all(WalletSpacing.lg),
            children: [
              SectionCard(
                title: AppString.walletPublicKeyLabel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (access != null) ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(WalletSpacing.md),
                          decoration: BoxDecoration(
                            color: WalletColors.surface,
                            borderRadius: BorderRadius.circular(WalletRadius.lg),
                            border: Border.all(
                              color: WalletColors.border,
                              width: 1.5,
                            ),
                            boxShadow: WalletShadows.level1,
                          ),
                          child: QrImageView(
                            data: access.publicKey,
                            version: QrVersions.auto,
                            size: 190,
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
                      const SizedBox(height: WalletSpacing.lg),
                    ],
                    Container(
                      padding: const EdgeInsets.all(WalletSpacing.md),
                      decoration: BoxDecoration(
                        color: WalletColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(WalletRadius.md),
                        border: Border.all(color: WalletColors.border),
                      ),
                      child: SelectableText(
                        access?.publicKey ?? AppString.walletActivateFirstMessage,
                        style: WalletTextStyles.mono,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: WalletSpacing.lg),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: access == null ? null : controller.copyPublicKey,
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text(
                          AppString.walletCopyPublicKey,
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
