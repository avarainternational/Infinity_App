import 'package:flutter/material.dart';
import 'package:infinity_wellness/app/features/wallet/utility/wallet_ui_metrics.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.trailing,
  });

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WalletColors.surface,
        borderRadius: BorderRadius.circular(WalletRadius.lg),
        border: Border.all(color: WalletColors.border, width: 1),
        boxShadow: WalletShadows.level1,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(WalletSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: WalletColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: WalletSpacing.md),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
