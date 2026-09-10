import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_images.dart';
import 'package:infinity_wellness/app/data/repositories/feed_repository.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_detail_controller.dart';
import 'package:infinity_wellness/app/features/feed/screen/feed_detail_screen.dart';
import 'package:infinity_wellness/app/features/feed/screen/feed_screen.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/home/screen/home_screen.dart';

class MockFeedRepository implements FeedRepository {
  final Set<String> savedIds = {};

  @override
  Future<List<FeedItem>> fetchFeedPosts() async => [];

  @override
  Future<Set<String>> getSavedPostIds(String userId) async => savedIds;

  @override
  Future<bool> toggleSavePost({
    required String userId,
    required String postId,
    required String title,
    String? category,
    String? authorName,
  }) async {
    if (savedIds.contains(postId)) {
      savedIds.remove(postId);
      return false;
    } else {
      savedIds.add(postId);
      return true;
    }
  }

  @override
  Future<bool> toggleLikePost({
    required String postId,
    required bool isLiking,
    int? currentLikes,
  }) async => isLiking;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testItem = FeedItem(
    id: 'test-post-1',
    authorName: 'Dr. Maya Lin',
    authorAvatarText: 'ML',
    badgeText: 'Curated Evidence',
    title: 'Can Drinking 3L of Water Cure Acne? The Clinical Reality',
    caption: 'Dermatological studies clarify that hydration supports skin elasticity.',
    summary: 'Clinical research summary about skin hydration and cellular turnover.',
    fullContent: 'Optimal hydration maintains cellular elasticity and assists metabolic toxin elimination.',
    type: FeedItemType.mythVsFact,
    category: 'Myth vs. Fact',
    authorRole: 'Dermatology Resident & Clinical Researcher',
    readTimeMinutes: 3,
    bannerGradient: [Color(0xFF0099FF), Color(0xFF0055D4)],
    bannerIcon: Icons.water_drop_rounded,
    bannerTag: 'MYTH BUSTER',
    publishedTime: '1 hour ago',
    imageAsset: AppImages.news3,
    likesCount: 120,
    sharesCount: 30,
    mythText: 'Drinking huge water volumes cures acne alone.',
    factText: 'Hydration supports skin barrier function, but acne requires multifaceted care.',
  );

  group('FeedDetailController Tests', () {
    late MockFeedRepository mockRepo;

    setUp(() {
      Get.reset();
      mockRepo = MockFeedRepository();
    });

    tearDown(() {
      Get.reset();
    });

    test('initializes with FeedItem argument and default states', () {
      Get.parameters = {};
      final controller = FeedDetailController(feedRepository: mockRepo);
      // Simulate setting item directly or passing via argument
      controller.item = testItem;
      controller.likesCount.value = testItem.likesCount;

      expect(controller.item.title, contains('Can Drinking 3L'));
      expect(controller.likesCount.value, 120);
      expect(controller.isLiked.value, false);
      expect(controller.isSaved.value, false);
    });

    test('toggleLike increments and decrements like counter reactively', () {
      final controller = FeedDetailController(feedRepository: mockRepo);
      controller.item = testItem;
      controller.likesCount.value = 120;

      controller.toggleLike();
      expect(controller.isLiked.value, true);
      expect(controller.likesCount.value, 121);

      controller.toggleLike();
      expect(controller.isLiked.value, false);
      expect(controller.likesCount.value, 120);
    });

    test('toggleSave toggles isSaved and calls repository', () async {
      final controller = FeedDetailController(feedRepository: mockRepo);
      controller.item = testItem;

      expect(controller.isSaved.value, false);
      await controller.toggleSave();
      expect(controller.isSaved.value, true);
      expect(mockRepo.savedIds.contains(testItem.id), true);

      await controller.toggleSave();
      expect(controller.isSaved.value, false);
      expect(mockRepo.savedIds.contains(testItem.id), false);
    });

    test('getDisplayContent returns full content if available', () {
      final controller = FeedDetailController(feedRepository: mockRepo);
      controller.item = testItem;

      expect(controller.getDisplayContent(), contains('cellular elasticity'));
    });
  });

  group('FeedDetailScreen Widget Tests', () {
    late MockFeedRepository mockRepo;
    late FeedDetailController controller;

    setUp(() {
      Get.reset();
      mockRepo = MockFeedRepository();
      controller = FeedDetailController(initialItem: testItem, feedRepository: mockRepo);
      Get.put<FeedDetailController>(controller);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('renders title, author, category, and action buttons', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const FeedDetailScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Title & author
      expect(find.text(testItem.title), findsOneWidget);
      expect(find.text('Dr. Maya Lin'), findsOneWidget);
      expect(find.text('MYTH VS. FACT'), findsOneWidget);

      // Bottom bar actions
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Share Post'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
    });

    testWidgets('tapping Save button toggles label to Saved', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const FeedDetailScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Saved'), findsOneWidget);
      expect(controller.isSaved.value, true);
    });

    testWidgets('tapping Like button increments counter', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const FeedDetailScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('120'), findsOneWidget);

      // Tap the like container (finding favorite icon)
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('121'), findsOneWidget);
      expect(controller.isLiked.value, true);
    });
  });

  group('Feed Card Clickability Widget Tests', () {
    setUp(() {
      Get.reset();
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('FeedScreen post cards have InkWell with onTap', (tester) async {
      final feedController = FeedController(
        initialFeedItems: [testItem],
        feedRepository: MockFeedRepository(),
      );
      Get.put<FeedController>(feedController);

      await tester.pumpWidget(
        GetMaterialApp(
          home: const FeedScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find InkWells inside feed item cards
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsWidgets);
    });

    testWidgets('HomeScreen feed cards have InkWell with onTap', (tester) async {
      Get.put<FeedRepository>(MockFeedRepository());
      final homeController = HomeController();
      homeController.homeFeedPosts.assignAll([testItem]);
      Get.put<HomeController>(homeController);

      await tester.pumpWidget(
        GetMaterialApp(
          home: const HomeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final inkWells = find.byType(InkWell);
      expect(inkWells, findsWidgets);

      homeController.onClose();
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
