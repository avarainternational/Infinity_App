import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/features/wallet/controller/wallet_controller.dart';

class RewardsShopController extends BaseController {
  final selectedCategory = 'All'.obs;
  final categories = const [
    'All',
    'Gear',
    'Nutrition',
    'Power-ups',
    'Vouchers',
  ];

  final shopItems = const <RewardShopItem>[
    RewardShopItem(
      id: 'item-bottle',
      title: 'Infinity PureFlow™ UV-C Bottle',
      category: 'Gear',
      description:
          'Self-cleaning 750ml smart bottle with UV-C purification & 24h temp retention.',
      pointsCost: 850,
      icon: Icons.local_drink_rounded,
      badge: 'POPULAR',
      gradient: [Color(0xFF0099FF), Color(0xFF0055D4)],
      originalPriceString: '\$45 Value',
    ),
    RewardShopItem(
      id: 'item-drops',
      title: 'HydroMax+ Electrolyte Drops',
      category: 'Nutrition',
      description:
          'Sugar-free cellular hydration drops (60ml bottle, 60 servings).',
      pointsCost: 300,
      icon: Icons.bolt_rounded,
      badge: 'BESTSELLER',
      gradient: [Color(0xFF0D9488), Color(0xFF047857)],
      originalPriceString: '\$18 Value',
    ),
    RewardShopItem(
      id: 'item-shield',
      title: 'Synergy Streak Freeze Shield',
      category: 'Power-ups',
      description:
          'Protects your 1-on-1 partner synergy streak if either misses 1 day.',
      pointsCost: 150,
      icon: Icons.shield_rounded,
      badge: 'PERK',
      gradient: [Color(0xFFFF6D00), Color(0xFFE64A19)],
      originalPriceString: 'Power-up',
    ),
    RewardShopItem(
      id: 'item-voucher-20',
      title: '20% Off Infinity Store Voucher',
      category: 'Vouchers',
      description:
          'Redeemable on all official Infinity Water filters, tumblers, and apparel.',
      pointsCost: 200,
      icon: Icons.confirmation_number_rounded,
      badge: 'DISCOUNT',
      gradient: [Color(0xFF7C3AED), Color(0xFF4338CA)],
      originalPriceString: '20% OFF',
    ),
    RewardShopItem(
      id: 'item-theme',
      title: 'Cyber Teal Neon UI Theme',
      category: 'Customization',
      description:
          'Exclusive animated cyber gauge and neon glow for your wellness companion.',
      pointsCost: 100,
      icon: Icons.palette_rounded,
      badge: 'EXCLUSIVE',
      gradient: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      originalPriceString: 'Digital Skin',
    ),
  ];

  List<RewardShopItem> get filteredShopItems {
    final cat = selectedCategory.value;
    if (cat == 'All') return shopItems;
    return shopItems.where((item) => item.category == cat).toList();
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }

  String get currentPoints {
    if (Get.isRegistered<WalletController>()) {
      return Get.find<WalletController>().currentBalance.value;
    }
    return '0';
  }

  void redeemItem(RewardShopItem item) {
    if (Get.isRegistered<WalletController>()) {
      Get.find<WalletController>().redeemRewardItem(item);
    } else {
      Get.snackbar(
        'Redeemed ${item.title}',
        'Use code INF-${item.id.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 10000}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
      );
    }
  }
}
