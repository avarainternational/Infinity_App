import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/constant/resources/app_images.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:infinity_wellness/app/data/repositories/feed_repository.dart';
import 'package:infinity_wellness/app/data/services/auth_service.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';

class FeedDetailController extends BaseController {
  FeedDetailController({
    FeedItem? initialItem,
    FeedRepository? feedRepository,
    AuthService? authService,
  })  : _initialItem = initialItem,
        _feedRepository = feedRepository ??
            (Get.isRegistered<FeedRepository>()
                ? Get.find<FeedRepository>()
                : FeedRepositoryImpl()),
        _authService = authService ??
            (Get.isRegistered<AuthService>() ? AuthService.to : null);

  final FeedItem? _initialItem;
  final FeedRepository _feedRepository;
  final AuthService? _authService;

  late FeedItem item;

  final isSaved = false.obs;
  final isLiked = false.obs;
  final likesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (_initialItem != null) {
      item = _initialItem;
    } else if (args is FeedItem) {
      item = args;
    } else {
      // Fallback default item if accessed without arguments
      item = const FeedItem(
        id: 'default-feed-detail',
        authorName: 'Infinity Health Desk',
        authorAvatarText: 'IH',
        badgeText: 'Curated Evidence',
        title: 'Evidence-Based Daily Hydration & Cellular Health',
        caption: 'Explore essential clinical facts and metabolic insights about optimal daily water intake.',
        summary: 'Clinical studies show that meeting personalized daily hydration goals maintains organ function and cellular resilience.',
        fullContent: 'Adequate hydration maintains cardiovascular efficiency, aids digestion, enhances skin barrier integrity, and optimizes cognitive performance throughout the day.',
        type: FeedItemType.medicalNews,
        category: 'Medical News',
        authorRole: 'Medical Advisory Panel',
        readTimeMinutes: 3,
        bannerGradient: [Color(0xFF0099FF), Color(0xFF0055D4)],
        bannerIcon: Icons.water_drop_rounded,
        bannerTag: 'CLINICAL INSIGHT',
        publishedTime: 'Today',
        imageAsset: AppImages.news3,
        likesCount: 142,
        sharesCount: 45,
      );
    }

    likesCount.value = item.likesCount;

    // Check if post is saved in FeedController or repository
    if (Get.isRegistered<FeedController>()) {
      isSaved.value = Get.find<FeedController>().isSaved(item.id);
    } else {
      final userId = _authService?.currentUser.value?.id ?? '';
      if (userId.isNotEmpty) {
        _feedRepository.getSavedPostIds(userId).then((ids) {
          isSaved.value = ids.contains(item.id);
        });
      }
    }
  }

  Future<void> toggleSave() async {
    final userId = _authService?.currentUser.value?.id ?? '';
    final newSaved = !isSaved.value;
    isSaved.value = newSaved;

    // Sync with FeedController if registered
    if (Get.isRegistered<FeedController>()) {
      final fc = Get.find<FeedController>();
      if (newSaved) {
        fc.savedPostIds.add(item.id);
      } else {
        fc.savedPostIds.remove(item.id);
      }
    }

    await _feedRepository.toggleSavePost(
      userId: userId,
      postId: item.id,
      title: item.title,
      category: item.category,
      authorName: item.authorName,
    );

    if (Get.context != null) {
      Get.snackbar(
        newSaved ? 'Saved to Bookmarks! 🔖' : 'Post Removed',
        newSaved
            ? 'Article saved to your personal library for quick offline reading.'
            : 'Article removed from your saved bookmarks.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: AppColors.textDark,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void toggleLike() {
    isLiked.value = !isLiked.value;
    if (isLiked.value) {
      likesCount.value++;
      if (Get.context != null) {
        Get.snackbar(
          'Liked! ❤️',
          'Thank you for supporting community health knowledge.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.white,
          colorText: AppColors.textDark,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } else {
      if (likesCount.value > 0) {
        likesCount.value--;
      }
    }
  }

  void sharePost() {
    final shareText = '''
${item.title}

${item.caption.isNotEmpty ? item.caption : item.summary}

Shared via Infinity Wellness App
''';
    Clipboard.setData(ClipboardData(text: shareText.trim()));

    if (Get.context != null) {
      Get.snackbar(
        'Link & Content Copied! 🔗',
        'Post details and shareable summary copied to clipboard.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: AppColors.textDark,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  String getDisplayContent() {
    if (item.fullContent.trim().isNotEmpty) {
      return item.fullContent.trim();
    }
    if (item.summary.trim().isNotEmpty) {
      return item.summary.trim();
    }

    // Curated contextual fallback body for titles
    if (item.title.contains('သုံးလီတာ') || item.title.contains('3L')) {
      return '''
တစ်နေ့လျှင် ရေ ၂.၅ လီတာမှ ၃ လီတာအထိ ပုံမှန်သောက်သုံးပေးခြင်းသည် ခန္ဓာကိုယ်ကျန်းမာရေးအတွက် မရှိမဖြစ်လိုအပ်သော အလေ့အကျင့်ကောင်းတစ်ခုဖြစ်ပါသည်။

အဓိက ကျန်းမာရေး အကျိုးကျေးဇူးများ -

၁။ ဇီဝကမ္မဖြစ်စဉ် (Metabolism) ကို မြှင့်တင်ပေးခြင်း
မနက်အိပ်ရာထချိန်နှင့် တစ်နေ့တာလုံးတွင် ရေကို မျှတစွာ သောက်သုံးပေးခြင်းက ခန္ဓာကိုယ်၏ ကယ်လိုရီလောင်ကျွမ်းနှုန်းကို ၃၀% အထိ တိုးမြှင့်ပေးနိုင်ပါသည်။

၂။ အသားအရေ စိုပြေကြည်လင်စေခြင်း
ဆဲလ်များအတွင်း ရေဓာတ်ပြည့်ဝနေခြင်းက အသားအရေခြောက်သွေ့ခြင်းမှ ကာကွယ်ပေးပြီး အရေးအကြောင်းဖြစ်ပေါ်မှုကို လျှော့ချပေးပါသည်။

၃။ ကျောက်ကပ်နှင့် အဆိပ်အတောက်စွန့်ထုတ်မှု ကောင်းမွန်စေခြင်း
ရေလုံလောက်စွာ သောက်ခြင်းသည် ဆီးလမ်းကြောင်းပိုးဝင်ခြင်းနှင့် ကျောက်ကပ်ကျောက်တည်ခြင်းမှ သိသိသာသာ ကာကွယ်ပေးပါသည်။

၄။ ဦးနှောက်စွမ်းဆောင်ရည်နှင့် မှတ်ဉာဏ် တိုးတက်စေခြင်း
ခန္ဓာကိုယ်အတွင်း ရေဓာတ် ၁% မှ ၂% အထိ လျော့နည်းသွားရုံမျှဖြင့် ခေါင်းကိုက်ခြင်း၊ အာရုံစူးစိုက်ရခက်ခဲခြင်းနှင့် မောပန်းနွမ်းနယ်ခြင်းတို့ကို ဖြစ်ပေါ်စေနိုင်ပါသည်။
''';
    }

    if (item.title.contains('မနက်အိပ်ရာထ') || item.title.contains('အိပ်ရာထ')) {
      return '''
ညအိပ်စက်ချိန် ၆ နာရီမှ ၈ နာရီအတွင်း ခန္ဓာကိုယ်သည် ရေဓာတ်သောက်သုံးမှုမရှိဘဲ အသက်ရှူခြင်းနှင့် ချွေးထွက်ခြင်းတို့ကြောင့် ရေဓာတ်လျော့နည်းနေလေ့ရှိပါသည်။

မနက်နိုးနိုးချင်း ရေတစ်ဖန်ခွက် သောက်ပေးသင့်သည့် အကြောင်းအရင်းများ -

၁။ ရေဓာတ်ချက်ချင်း ပြန်လည်ဖြည့်တင်းပေးခြင်း
ညတွင်းချင်း ဆုံးရှုံးသွားသော ရေဓာတ်ကို အလျင်အမြန် ပြန်လည်ဖြည့်ဆည်းပေးပြီး ဆဲလ်များနှင့် ကြွက်သားများကို နိုးကြားတက်ကြွစေပါသည်။

၂။ အစာခြေလမ်းကြောင်းနှင့် အူလမ်းကြောင်း သန့်စင်စေခြင်း
မနက်စောစော သောက်သောရေသည် အူလမ်းကြောင်း လှုပ်ရှားမှုကို လှုံ့ဆော်ပေးပြီး ဝမ်းချုပ်ခြင်းကို ကာကွယ်ပေးပါသည်။

၃။ သွေးလှည့်ပတ်မှု ကောင်းမွန်စေခြင်း
သွေးပျစ်ခဲမှုကို လျှော့ချပေးပြီး နှလုံးနှင့် သွေးကြောစနစ်ကို ပုံမှန်လည်ပတ်စေရန် အထောက်အကူပြုပါသည်။

၄။ ခံတွင်းနှင့် ကိုယ်ခံအားစနစ် ကောင်းမွန်စေခြင်း
ခံတွင်းခြောက်သွေ့မှုကို သက်သာစေပြီး ဇီဝဖြစ်စဉ်ကို နိုးကြားစေကာ တစ်နေ့တာလုံး တက်ကြွလန်းဆန်းစေပါသည်။
''';
    }

    return item.caption;
  }
}
