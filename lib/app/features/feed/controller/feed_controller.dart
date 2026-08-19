import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';

enum FeedItemType { medicalNews, mythVsFact, announcement }

class FeedItem {
  const FeedItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.type,
    required this.category,
    required this.authorRole,
    required this.readTimeMinutes,
    this.mythText,
    this.factText,
  });

  final String id;
  final String title;
  final String summary;
  final FeedItemType type;
  final String category;
  final String authorRole;
  final int readTimeMinutes;
  final String? mythText;
  final String? factText;
}

class FeedController extends BaseController {
  final selectedCategory = 'All'.obs;
  final categories = const ['All', 'Medical News', 'Myth vs. Fact', 'Ecosystem'];

  final feedItems = const <FeedItem>[
    FeedItem(
      id: 'feed-1',
      title: 'Can Drinking 3L of Water Cure Acne? The Clinical Reality',
      summary:
          'Dermatological studies show that while optimal hydration maintains skin elasticity and barrier function, it does not replace targeted acne care.',
      type: FeedItemType.mythVsFact,
      category: 'Dermatology & Hydration',
      authorRole: 'Verified by Med Student, Year 4',
      readTimeMinutes: 3,
      mythText: 'Drinking extreme amounts of water completely eliminates acne.',
      factText:
          'Hydration supports skin cell turnover and toxin filtration via kidneys, but acne is driven by sebum, hormones, and bacteria.',
    ),
    FeedItem(
      id: 'feed-2',
      title: 'Optimal Electrolyte Balance During Youth Physical Activity',
      summary:
          'Understanding sodium, potassium, and magnesium loss during high-intensity training and the best natural replenishment methods.',
      type: FeedItemType.medicalNews,
      category: 'Sports & Physiology',
      authorRole: 'Curated by Medical Resident',
      readTimeMinutes: 4,
    ),
    FeedItem(
      id: 'feed-3',
      title: 'Infinity Wellness Ecosystem Launch: Phase 1 Mini-Apps',
      summary:
          'Discover our 3 dedicated digital health modules: Medical News, Smart Hydration, and 1-on-1 Friend Synergy.',
      type: FeedItemType.announcement,
      category: 'Ecosystem News',
      authorRole: 'Infinity Water Health Team',
      readTimeMinutes: 2,
    ),
    FeedItem(
      id: 'feed-4',
      title: 'Screen Time & Sleep Quality: Debunking Blue Light Myths',
      summary:
          'How circadian melatonin release is regulated by evening light spectrums and practical night-time digital hygiene tips.',
      type: FeedItemType.medicalNews,
      category: 'Mental Health & Sleep',
      authorRole: 'Verified by Neuroscience Student',
      readTimeMinutes: 5,
    ),
  ].obs;

  List<FeedItem> get filteredItems {
    if (selectedCategory.value == 'All') {
      return feedItems;
    }
    if (selectedCategory.value == 'Medical News') {
      return feedItems.where((i) => i.type == FeedItemType.medicalNews).toList();
    }
    if (selectedCategory.value == 'Myth vs. Fact') {
      return feedItems.where((i) => i.type == FeedItemType.mythVsFact).toList();
    }
    if (selectedCategory.value == 'Ecosystem') {
      return feedItems.where((i) => i.type == FeedItemType.announcement).toList();
    }
    return feedItems;
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }
}
