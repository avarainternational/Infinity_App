import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';

abstract class FeedRepository {
  Future<List<FeedItem>> fetchFeedPosts();
  Future<Set<String>> getSavedPostIds(String userId);
  Future<bool> toggleSavePost({
    required String userId,
    required String postId,
    required String title,
    String? category,
    String? authorName,
  });
  Future<bool> toggleLikePost({
    required String postId,
    required bool isLiking,
    int? currentLikes,
  });
}

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? (Get.isRegistered<SupabaseService>() ? SupabaseService.to : null);

  final SupabaseService? _supabaseService;

  final Set<String> _localSavedPostIds = {};
  final Set<String> _localLikedPostIds = {};

  bool get _isLive => _supabaseService?.isInitialized == true && _supabaseService?.config.isConfigured == true;

  @override
  Future<List<FeedItem>> fetchFeedPosts() async {
    if (_isLive) {
      try {
        final response = await _supabaseService!.client
            .from('feed_posts')
            .select('*')
            .eq('is_published', true)
            .order('published_at', ascending: false);

        final list = (response as List<dynamic>)
            .map((row) => FeedItem.fromJson(row as Map<String, dynamic>))
            .toList();

        return list;
      } catch (e) {
        debugPrint('⚠️ Error fetching feed posts from Supabase: $e');
        return [];
      }
    }
    return FeedController.sampleFeedItems;
  }

  @override
  Future<Set<String>> getSavedPostIds(String userId) async {
    if (userId.isEmpty) return _localSavedPostIds;

    if (_isLive) {
      try {
        final response = await _supabaseService!.client
            .from('saved_feed_posts')
            .select('post_id')
            .eq('user_id', userId);

        final ids = (response as List<dynamic>)
            .map((row) => row['post_id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();

        _localSavedPostIds.addAll(ids);
        return ids;
      } catch (e) {
        debugPrint('⚠️ Error fetching saved post IDs from Supabase: $e');
      }
    }

    return _localSavedPostIds;
  }

  @override
  Future<bool> toggleSavePost({
    required String userId,
    required String postId,
    required String title,
    String? category,
    String? authorName,
  }) async {
    final isCurrentlySaved = _localSavedPostIds.contains(postId);

    if (isCurrentlySaved) {
      _localSavedPostIds.remove(postId);
    } else {
      _localSavedPostIds.add(postId);
    }

    if (_isLive && userId.isNotEmpty) {
      try {
        if (isCurrentlySaved) {
          await _supabaseService!.client
              .from('saved_feed_posts')
              .delete()
              .eq('user_id', userId)
              .eq('post_id', postId);
        } else {
          await _supabaseService!.client.from('saved_feed_posts').insert({
            'user_id': userId,
            'post_id': postId,
            'title': title,
            'category': category ?? 'General',
            'author_name': authorName ?? 'Infinity Author',
          });
        }
      } catch (e) {
        debugPrint('⚠️ Error updating saved post in Supabase: $e');
      }
    }

    return !isCurrentlySaved;
  }

  @override
  Future<bool> toggleLikePost({
    required String postId,
    required bool isLiking,
    int? currentLikes,
  }) async {
    if (isLiking) {
      _localLikedPostIds.add(postId);
    } else {
      _localLikedPostIds.remove(postId);
    }

    if (_isLive && postId.isNotEmpty && currentLikes != null) {
      try {
        final newCount = isLiking ? currentLikes + 1 : (currentLikes > 0 ? currentLikes - 1 : 0);
        await _supabaseService!.client
            .from('feed_posts')
            .update({'likes_count': newCount})
            .eq('id', postId);
      } catch (e) {
        debugPrint('⚠️ Error updating likes count in Supabase: $e');
      }
    }

    return isLiking;
  }
}
