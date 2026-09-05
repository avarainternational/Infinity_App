import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_string.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/wallet/controller/wallet_controller.dart';
import 'package:infinity_wellness/app/features/wallet/model/wallet_transaction_history_model.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';
import 'package:infinity_wellness/app/widget/section_card.dart';

class WalletTransactionHistoryScreen extends BaseView<WalletController> {
  const WalletTransactionHistoryScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: WalletColors.background,
      appBar: AppBar(
        title: const Text(
          AppString.walletHistoryTitle,
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
          final records = controller.history;
          if (records.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(WalletSpacing.lg),
              children: const [
                SectionCard(
                  title: AppString.walletHistoryTitle,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: WalletSpacing.md),
                    child: Text(
                      AppString.walletNoHistory,
                      style: WalletTextStyles.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(WalletSpacing.lg),
            itemBuilder: (_, index) => _HistoryTile(record: records[index]),
            separatorBuilder: (_, _) =>
                const SizedBox(height: WalletSpacing.sm),
            itemCount: records.length,
          );
        }),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});

  final WalletTransactionHistoryModel record;

  @override
  Widget build(BuildContext context) {
    final isSuccess = record.status == WalletTransactionStatus.success;
    final amountText = '${record.amount} ${record.assetCode}';
    final routeText =
        '${_short(record.senderPublicKey)} → ${_short(record.recipientPublicKey)}';

    return Container(
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.lg),
        border: Border.all(color: WalletColors.border, width: 1),
        boxShadow: WalletShadows.level1,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: WalletSpacing.md,
          vertical: WalletSpacing.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSuccess ? WalletColors.successBg : WalletColors.errorBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSuccess
                  ? WalletColors.successBorder
                  : WalletColors.errorBorder,
            ),
          ),
          child: Center(
            child: Icon(
              isSuccess
                  ? Icons.arrow_outward_rounded
                  : Icons.error_outline_rounded,
              size: 20,
              color: isSuccess ? WalletColors.success : WalletColors.error,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              amountText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: WalletColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: WalletSpacing.sm,
                vertical: WalletSpacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: isSuccess ? WalletColors.successBg : WalletColors.errorBg,
                borderRadius: BorderRadius.circular(WalletRadius.xs),
                border: Border.all(
                  color: isSuccess
                      ? WalletColors.successBorder
                      : WalletColors.errorBorder,
                ),
              ),
              child: Text(
                isSuccess
                    ? AppString.walletTransactionSuccess
                    : AppString.walletTransactionFailed,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSuccess ? WalletColors.success : WalletColors.error,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: WalletSpacing.xxs),
          child: Text(
            routeText,
            style: WalletTextStyles.bodyMuted,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: WalletColors.textMuted,
        ),
        onTap: () => _showDetailsModal(context),
      ),
    );
  }

  void _showDetailsModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: WalletColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WalletRadius.lg),
          side: const BorderSide(color: WalletColors.border),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${record.amount} ${record.assetCode}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: WalletColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, size: 20),
              color: WalletColors.textMuted,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Detail(
                AppString.walletRecipientLabel,
                record.recipientPublicKey,
              ),
              _Detail(
                AppString.walletPublicKeyLabel,
                record.senderPublicKey,
              ),
              _Detail(AppString.walletNetworkLabel, record.network),
              if (record.transactionHash?.isNotEmpty == true)
                _Detail(
                  AppString.walletTransactionHashLabel,
                  record.transactionHash!,
                ),
              if (record.errorMessage?.isNotEmpty == true)
                _Detail(AppString.walletErrorLabel, record.errorMessage!),
            ],
          ),
        ),
      ),
    );
  }

  String _short(String value) {
    if (value.length <= 12) {
      return value;
    }
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);

  final String label;
  final String value;

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
              vertical: WalletSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: WalletColors.surfaceMuted,
              borderRadius: BorderRadius.circular(WalletRadius.sm),
              border: Border.all(color: WalletColors.border),
            ),
            child: SelectableText(
              value,
              style: WalletTextStyles.mono,
            ),
          ),
        ],
      ),
    );
  }
}
