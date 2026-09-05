import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';
import 'package:infinity_wellness/app/features/feed/screen/feed_screen.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/home/screen/home_screen.dart';
import 'package:infinity_wellness/app/features/mini_app_store/controller/mini_app_store_controller.dart';
import 'package:infinity_wellness/app/features/mini_app_store/screen/mini_app_store_screen.dart';
import 'package:infinity_wellness/app/features/achievements/controller/achievements_controller.dart';
import 'package:infinity_wellness/app/features/achievements/screen/achievements_screen.dart';
import 'package:infinity_wellness/app/features/profile/controller/profile_controller.dart';
import 'package:infinity_wellness/app/features/profile/screen/profile_screen.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('FeedController News & Expand Logic', () {
    test('initializes with verified medical news items and banner graphics', () {
      final controller = Get.put(FeedController());
      expect(controller.feedItems.length, greaterThanOrEqualTo(4));

      final firstItem = controller.feedItems.first;
      expect(firstItem.authorName, equals('M Travel'));
      expect(firstItem.badgeText, equals('Promoted By'));
      expect(firstItem.bannerGradient.length, greaterThanOrEqualTo(2));
      expect(controller.isExpanded(firstItem.id), isFalse);
    });

    test('toggles expand and collapse states', () {
      final controller = Get.put(FeedController());
      const testId = 'feed-1';

      expect(controller.isExpanded(testId), isFalse);
      controller.toggleExpand(testId);
      expect(controller.isExpanded(testId), isTrue);

      controller.toggleExpand(testId);
      expect(controller.isExpanded(testId), isFalse);
    });

    test('toggles save and bookmark status', () {
      final controller = Get.put(FeedController());
      const testId = 'feed-1';

      final item = controller.feedItems.firstWhere((i) => i.id == testId);
      expect(controller.isSaved(testId), isFalse);
      controller.toggleSave(item);
      expect(controller.isSaved(testId), isTrue);
      controller.toggleSave(item);
      expect(controller.isSaved(testId), isFalse);
    });

    test('loads leaderboard users with premium vector icons and ranks', () {
      final controller = Get.put(FeedController());
      expect(controller.leaderboardUsers.length, greaterThanOrEqualTo(5));
      expect(controller.leaderboardUsers.first.rank, equals(1));
      expect(controller.leaderboardUsers.first.badgeTitle, equals('Hydration Deity'));
      expect(controller.leaderboardUsers.first.icon, equals(Icons.workspace_premium_rounded));
    });
  });

  group('FeedScreen News Card Widget Tests', () {
    testWidgets('renders 16:9 visual graphic news cards with placeholder images',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = Get.put(FeedController());
      controller.activeTab.value = SocialTab.feed;

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: FeedScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Social & Feed'), findsOneWidget);

      // Verify 16:9 AspectRatio and Image widgets exist
      final aspectRatios = tester.widgetList<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatios.any((ar) => (ar.aspectRatio - (16 / 9)).abs() < 0.01), isTrue);
      expect(find.byType(Image), findsWidgets);

      // Verify NO extra text clutter / buttons are rendered on cards
      expect(find.text('Read Full Article'), findsNothing);
      expect(find.textContaining('Helpful'), findsNothing);
      expect(find.text('Show Less'), findsNothing);
      expect(find.text('Verified by Dr. Maya Lin & Med Student Cohort'), findsNothing);
    });
  });

  group('HomeScreen News & Challenges Widget Tests', () {
    testWidgets('renders home news cards as 16:9 graphic cards with placeholder images', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.put(ShellController());
      final homeController = Get.put(HomeController());
      homeController.homeFeedPosts.assignAll(FeedController.defaultFeedItems);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to News & Community Feed
      await tester.scrollUntilVisible(
        find.text('News & Community Feed'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('News & Community Feed'), findsOneWidget);

      // Verify 16:9 card and images in home
      final aspectRatios = tester.widgetList<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatios.any((ar) => (ar.aspectRatio - (16 / 9)).abs() < 0.01), isTrue);
      expect(find.byType(Image), findsWidgets);
      expect(find.text('Read Full Article'), findsNothing);
      expect(find.text('Show Less'), findsNothing);

      homeController.onClose();
      await tester.pump();
    });

    testWidgets('renders quick mini-apps with matched icons and More navigates to mini-apps tab', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final shellController = Get.put(ShellController());
      final feedController = Get.put(FeedController());
      final homeController = Get.put(HomeController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to Quick miniapps
      await tester.scrollUntilVisible(
        find.text('Quick miniapps'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Quick miniapps'), findsOneWidget);

      // Verify quick mini-apps tiles and icons
      expect(find.text('News'), findsOneWidget);
      expect(find.text('Hydration'), findsWidgets);
      expect(find.text('Synergy'), findsOneWidget);
      expect(find.text('More'), findsWidgets);

      expect(find.byIcon(Icons.article_rounded), findsWidgets);
      expect(find.byIcon(Icons.water_drop_rounded), findsWidgets);
      expect(find.byIcon(Icons.people_alt_rounded), findsWidgets);
      expect(find.byIcon(Icons.grid_view_rounded), findsWidgets);

      // Tap 'More' icon tile -> switches to Mini-Apps tab (index 3)
      await tester.tap(find.text('More').last);
      await tester.pumpAndSettle();
      expect(shellController.currentIndex.value, equals(3));

      // Reset to Home
      shellController.selectTab(2);
      await tester.pumpAndSettle();

      // Tap 'News' -> switches to Feed tab (index 1) and selects SocialTab.feed
      await tester.tap(find.text('News'));
      await tester.pumpAndSettle();
      expect(shellController.currentIndex.value, equals(1));
      expect(feedController.activeTab.value, equals(SocialTab.feed));

      homeController.onClose();
      await tester.pump();
    });
  });

  group('FeedScreen Challenges 16:9 Widget Tests', () {
    testWidgets('renders challenges as default tab with 16:9 graphic cards',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = Get.put(FeedController());
      controller.activeTab.value = SocialTab.challenges;

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: FeedScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify challenge titles & 16:9 AspectRatios
      expect(find.text('7-Day Smart Hydration Sprint'), findsOneWidget);
      expect(find.text('1-on-1 Synergy Streak Master'), findsOneWidget);

      final aspectRatios = tester.widgetList<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatios.any((ar) => (ar.aspectRatio - (16 / 9)).abs() < 0.01), isTrue);
    });
  });

  group('FeedScreen Leaderboard Widget Tests', () {
    testWidgets('renders leaderboard podiums and ranking list',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = Get.put(FeedController());
      controller.activeTab.value = SocialTab.leaderboard;

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: FeedScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify top 3 podium entries
      expect(find.text('Dr. Maya Lin'), findsOneWidget);
      expect(find.text('Alex & Elena'), findsOneWidget);
      expect(find.text('Kai Rivera'), findsOneWidget);

      // Verify YOU user highlighted entry
      expect(find.text('You (Infinity User)'), findsOneWidget);
      expect(find.text('YOU'), findsWidgets);
      expect(find.text('Rankings'), findsWidgets);
    });
  });

  group('MiniAppStoreScreen Vertical Category Layout Tests', () {
    testWidgets('renders mini app store with vertical categories and small icon + name tiles',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.put(MiniAppStoreController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: MiniAppStoreScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Mini-App Store'), findsOneWidget);

      // Verify vertical category titles
      expect(find.text('Health Literacy'), findsOneWidget);
      expect(find.text('Vitality & Intake'), findsOneWidget);
      expect(find.text('Mutual Accountability'), findsOneWidget);
      expect(find.text('Rewards & Gear'), findsOneWidget);

      // Verify mini-app titles
      expect(find.text('Hydration'), findsOneWidget);
      expect(find.text('Synergy'), findsOneWidget);
      expect(find.text('News'), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);
    });
  });

  group('ProfileScreen Achievements & Badges Widget Tests', () {
    testWidgets('renders achievements 3-icon showcase on profile page',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.put(ProfileController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify achievements header and view all button
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('View all'), findsOneWidget);

      // Verify 3 displayed achievement icons rendered
      expect(find.byIcon(Icons.water_drop_rounded), findsWidgets);
      expect(find.byIcon(Icons.people_alt_rounded), findsWidgets);
      expect(find.byIcon(Icons.school_rounded), findsWidgets);
    });
  });

  group('Achievements Mini-App Widget Tests', () {
    testWidgets('renders full achievements mini-app with stats, filters and catalog',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.put(AchievementsController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: AchievementsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Mini-App top bar and level stats
      expect(find.text('Achievements & Badges'), findsOneWidget);
      expect(find.text('Level 4 Pioneer'), findsOneWidget);
      expect(find.text('+190 pts Earned'), findsOneWidget);

      // Verify catalog entries
      expect(find.text('Hydration Hero'), findsOneWidget);
      expect(find.text('1-on-1 Synergy Master'), findsOneWidget);
      expect(find.text('Myth Buster Scholar'), findsOneWidget);
      expect(find.text('Hydration Sprint Champion'), findsOneWidget);
      expect(find.text('Digital Screen-Break Habit'), findsOneWidget);
      expect(find.text('Century Hydration Club'), findsOneWidget);
    });
  });
}
