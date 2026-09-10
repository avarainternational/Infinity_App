import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/models/user_profile_model.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:infinity_wellness/app/features/feed/controller/feed_controller.dart';

abstract class UserRepository {
  Future<UserProfileModel?> getUserProfile(String userId);
  Future<UserProfileModel> upsertProfile(UserProfileModel profile);
  Future<UserProfileModel?> updateHealthMetrics({
    required String userId,
    required double weightKg,
    required double heightCm,
    required String activityLevel,
    required int dailyWaterGoalMl,
  });
  Future<UserProfileModel?> updateDailyGoal(String userId, int goalMl);
  Future<UserProfileModel?> findUserByInviteCode(String inviteCode);
  Future<UserProfileModel?> addWellnessPoints(String userId, int points);
  Future<List<LeaderboardUser>> getLeaderboardUsers({String currentUserId = ''});
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? (Get.isRegistered<SupabaseService>() ? SupabaseService.to : null);

  final SupabaseService? _supabaseService;

  // Local fallback storage for offline & development mode
  final Map<String, UserProfileModel> _localProfileCache = {};

  bool get _isLive => _supabaseService?.isInitialized == true && _supabaseService?.config.isConfigured == true;

  @override
  Future<UserProfileModel?> getUserProfile(String userId) async {
    if (userId.isEmpty) return null;

    if (_isLive) {
      try {
        final response = await _supabaseService!.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .limit(1);

        if (response.isNotEmpty) {
          var profile = UserProfileModel.fromJson(response.first);
          // Ensure profile has an invite code
          if (profile.inviteCode.trim().isEmpty) {
            final generatedCode = UserProfileModel.generateInviteCode(profile.displayName);
            profile = profile.copyWith(inviteCode: generatedCode);
            await _supabaseService.client
                .from('profiles')
                .update({'invite_code': generatedCode})
                .eq('id', userId);
          }
          _localProfileCache[userId] = profile;
          return profile;
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching live profile from Supabase: $e');
      }
    }

    // Return cached profile if present, else null
    return _localProfileCache[userId];
  }

  @override
  Future<UserProfileModel> upsertProfile(UserProfileModel profile) async {
    // Ensure invite code is present
    var toSave = profile;
    if (toSave.inviteCode.trim().isEmpty) {
      toSave = toSave.copyWith(inviteCode: UserProfileModel.generateInviteCode(toSave.displayName));
    }
    _localProfileCache[toSave.id] = toSave;

    if (_isLive) {
      try {
        final data = toSave.toJson();
        final response = await _supabaseService!.client
            .from('profiles')
            .upsert(data)
            .select()
            .single();
        return UserProfileModel.fromJson(response);
      } catch (e) {
        debugPrint('⚠️ Error upserting live profile to Supabase: $e');
      }
    }

    return toSave;
  }

  @override
  Future<UserProfileModel?> updateHealthMetrics({
    required String userId,
    required double weightKg,
    required double heightCm,
    required String activityLevel,
    required int dailyWaterGoalMl,
  }) async {
    final existing = await getUserProfile(userId);
    final updated = (existing ?? UserProfileModel(id: userId, email: '', displayName: ''))
        .copyWith(
      weightKg: weightKg,
      heightCm: heightCm,
      activityLevel: activityLevel,
      dailyWaterGoalMl: dailyWaterGoalMl,
      updatedAt: DateTime.now(),
    );

    return upsertProfile(updated);
  }

  @override
  Future<UserProfileModel?> updateDailyGoal(String userId, int goalMl) async {
    final existing = await getUserProfile(userId);
    final updated = (existing ?? UserProfileModel(id: userId, email: '', displayName: ''))
        .copyWith(
      dailyWaterGoalMl: goalMl,
      updatedAt: DateTime.now(),
    );

    return upsertProfile(updated);
  }

  @override
  Future<UserProfileModel?> findUserByInviteCode(String inviteCode) async {
    final cleanCode = inviteCode.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;

    if (_isLive) {
      try {
        final response = await _supabaseService!.client
            .from('profiles')
            .select()
            .ilike('invite_code', cleanCode)
            .limit(1);

        if (response.isNotEmpty) {
          return UserProfileModel.fromJson(response.first);
        }
      } catch (e) {
        debugPrint('⚠️ Error looking up invite code: $e');
      }
    }

    // Look in local cache for matching code
    for (final profile in _localProfileCache.values) {
      if (profile.inviteCode.toUpperCase() == cleanCode) {
        return profile;
      }
    }

    return null;
  }

  @override
  Future<UserProfileModel?> addWellnessPoints(String userId, int points) async {
    if (userId.isEmpty || points <= 0) return null;

    final existing = await getUserProfile(userId);
    if (existing == null) return null;

    final newBalance = existing.wellnessPointsBalance + points;
    final updated = existing.copyWith(
      wellnessPointsBalance: newBalance,
      updatedAt: DateTime.now(),
    );

    _localProfileCache[userId] = updated;

    if (_isLive) {
      try {
        await _supabaseService!.client
            .from('profiles')
            .update({
              'wellness_points_balance': newBalance,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      } catch (e) {
        debugPrint('⚠️ Error updating wellness points in Supabase: $e');
      }
    }

    return updated;
  }

  @override
  Future<List<LeaderboardUser>> getLeaderboardUsers({String currentUserId = ''}) async {
    if (_isLive) {
      try {
        final response = await _supabaseService!.client
            .from('profiles')
            .select('id, display_name, avatar_url, wellness_points_balance, current_streak, daily_water_goal_ml')
            .order('wellness_points_balance', ascending: false)
            .limit(20);

        if (response.isNotEmpty) {
          int currentRank = 1;
          final list = <LeaderboardUser>[];

          for (final row in response) {
            final id = row['id']?.toString() ?? '';
            final name = row['display_name']?.toString() ?? 'Infinity Member';
            final points = (row['wellness_points_balance'] as num?)?.toInt() ?? 0;
            final streak = (row['current_streak'] as num?)?.toInt() ?? 0;
            final isUser = id == currentUserId;

            final initials = name.trim().isNotEmpty
                ? (name.trim().split(' ').length > 1
                    ? '${name.trim().split(' ')[0][0]}${name.trim().split(' ')[1][0]}'.toUpperCase()
                    : name.trim().substring(0, math.min(2, name.trim().length)).toUpperCase())
                : 'IW';

            // Assign premium icon and tier based on rank
            final IconData rankIcon;
            final Color rankColor;
            final String badgeTitle;
            final List<Color> gradient;

            if (currentRank == 1) {
              rankIcon = Icons.workspace_premium_rounded;
              rankColor = const Color(0xFFF59E0B);
              badgeTitle = 'Hydration Deity';
              gradient = const [Color(0xFFFEF3C7), Color(0xFFFDE68A)];
            } else if (currentRank == 2) {
              rankIcon = Icons.military_tech_rounded;
              rankColor = const Color(0xFF94A3B8);
              badgeTitle = 'Synergy Master';
              gradient = const [Color(0xFFF1F5F9), Color(0xFFE2E8F0)];
            } else if (currentRank == 3) {
              rankIcon = Icons.shield_rounded;
              rankColor = const Color(0xFFD97706);
              badgeTitle = 'Streak Champion';
              gradient = const [Color(0xFFFFF1EE), Color(0xFFFFEDD5)];
            } else {
              rankIcon = isUser ? Icons.star_rounded : Icons.diamond_outlined;
              rankColor = const Color(0xFF0284C7);
              badgeTitle = isUser ? 'Flame Keeper' : 'Vitality Pro';
              gradient = const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)];
            }

            list.add(LeaderboardUser(
              rank: currentRank,
              name: isUser ? '$name (You)' : name,
              initials: initials,
              points: points,
              streakDays: streak,
              hydrationPercent: 95,
              isCurrentUser: isUser,
              badgeTitle: badgeTitle,
              icon: rankIcon,
              iconColor: rankColor,
              avatarGradient: gradient,
            ));

            currentRank++;
          }

          return list;
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching live leaderboard from Supabase: $e');
      }
    }

    // Fallback structured leaderboard with premium vector icons
    return _getDefaultLeaderboardUsers(currentUserId);
  }

  List<LeaderboardUser> _getDefaultLeaderboardUsers(String currentUserId) {
    final cached = _localProfileCache[currentUserId];
    final userPoints = cached?.wellnessPointsBalance ?? 500;
    final userStreak = cached?.currentStreak ?? 7;
    final userName = cached?.displayName ?? 'Infinity User';

    return [
      const LeaderboardUser(
        rank: 1,
        name: 'Dr. Maya Lin',
        initials: 'ML',
        points: 2850,
        streakDays: 45,
        hydrationPercent: 98,
        badgeTitle: 'Hydration Deity',
        icon: Icons.workspace_premium_rounded,
        iconColor: Color(0xFFF59E0B),
        avatarGradient: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
      ),
      const LeaderboardUser(
        rank: 2,
        name: 'Alex & Elena',
        initials: 'AE',
        points: 2420,
        streakDays: 38,
        hydrationPercent: 95,
        badgeTitle: 'Synergy Master',
        icon: Icons.military_tech_rounded,
        iconColor: Color(0xFF94A3B8),
        avatarGradient: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
      ),
      const LeaderboardUser(
        rank: 3,
        name: 'Kai Rivera',
        initials: 'KR',
        points: 2190,
        streakDays: 31,
        hydrationPercent: 92,
        badgeTitle: 'Streak Champion',
        icon: Icons.shield_rounded,
        iconColor: Color(0xFFD97706),
        avatarGradient: [Color(0xFFFFF1EE), Color(0xFFFFEDD5)],
      ),
      LeaderboardUser(
        rank: 4,
        name: 'You ($userName)',
        initials: 'YOU',
        points: userPoints,
        streakDays: userStreak,
        hydrationPercent: 90,
        isCurrentUser: true,
        badgeTitle: 'Flame Keeper',
        icon: Icons.star_rounded,
        iconColor: const Color(0xFF0284C7),
        avatarGradient: const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
      ),
      const LeaderboardUser(
        rank: 5,
        name: 'Sarah Chen',
        initials: 'SC',
        points: 1720,
        streakDays: 21,
        hydrationPercent: 88,
        badgeTitle: 'Vitality Pro',
        icon: Icons.diamond_outlined,
        iconColor: Color(0xFF0284C7),
        avatarGradient: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
      ),
    ];
  }
}
