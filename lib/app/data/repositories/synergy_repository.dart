import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/models/synergy_models.dart';
import 'package:infinity_wellness/app/data/repositories/hydration_repository.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:infinity_wellness/app/features/partner/model/partner_detail_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SynergyRepository {
  Future<SynergyPairModel?> getActivePair(String userId);
  Future<SynergyPairModel> connectPartnerWithCode({
    required String currentUserId,
    required String inviteCode,
  });
  Future<void> disconnectPartner({required String pairId});
  Future<SynergyNudgeModel> sendNudge({
    required String senderId,
    required String receiverId,
    required SynergyNudgeType nudgeType,
    String? message,
  });
  Future<List<SynergyNudgeModel>> getRecentNudges(String userId);
  Future<int> getPartnerTodayIntake(String partnerId);
  Future<List<PartnerWaterLog>> getPartnerTodayWaterLogs(String partnerId);
  Future<List<PartnerDayRecord>> getPartnerPastDays(String partnerId, int goalMl);
  RealtimeChannel? subscribeToPartnerUpdates({
    required String currentUserId,
    required String partnerId,
    required void Function(int intakeMl) onPartnerWaterLogged,
    required void Function(SynergyNudgeModel nudge) onNudgeReceived,
  });
}

class SynergyRepositoryImpl implements SynergyRepository {
  SynergyRepositoryImpl({
    SupabaseService? supabaseService,
    UserRepository? userRepository,
    HydrationRepository? hydrationRepository,
  })  : _supabaseService = supabaseService ?? (Get.isRegistered<SupabaseService>() ? SupabaseService.to : null),
        _userRepository = userRepository ?? (Get.isRegistered<UserRepository>() ? Get.find<UserRepository>() : UserRepositoryImpl()),
        _hydrationRepository = hydrationRepository ?? (Get.isRegistered<HydrationRepository>() ? Get.find<HydrationRepository>() : null);

  final SupabaseService? _supabaseService;
  final UserRepository _userRepository;
  final HydrationRepository? _hydrationRepository;

  bool get _isLive => _supabaseService?.isInitialized == true && _supabaseService?.config.isConfigured == true;

  // Local fallback state
  SynergyPairModel? _localActivePair;
  final List<SynergyNudgeModel> _localNudges = [];

  @override
  Future<SynergyPairModel?> getActivePair(String userId) async {
    if (userId.isEmpty) return null;

    if (_isLive) {
      try {
        final response = await _supabaseService!.client
            .from('friend_synergy_pairs')
            .select()
            .or('user_a_id.eq.$userId,user_b_id.eq.$userId')
            .eq('status', 'active')
            .order('created_at', ascending: false)
            .limit(1);

        if (response.isNotEmpty) {
          final row = response.first;
          final pair = SynergyPairModel.fromJson(row, currentUserId: userId);
          final partnerId = pair.getPartnerId(userId);

          final partnerProfile = await _userRepository.getUserProfile(partnerId);
          final partnerIntake = await getPartnerTodayIntake(partnerId);

          _localActivePair = pair.copyWith(
            partnerProfile: partnerProfile,
            partnerTodayIntakeMl: partnerIntake,
          );
          return _localActivePair;
        } else {
          _localActivePair = null;
          return null;
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching live active pair: $e');
      }
    }

    return _localActivePair;
  }

  @override
  Future<SynergyPairModel> connectPartnerWithCode({
    required String currentUserId,
    required String inviteCode,
  }) async {
    final cleanCode = inviteCode.trim().toUpperCase();
    final partnerProfile = await _userRepository.findUserByInviteCode(cleanCode);
    if (partnerProfile == null) {
      throw Exception('No user found with invite code "$cleanCode". Please verify with your partner.');
    }

    if (partnerProfile.id == currentUserId) {
      throw Exception('You cannot pair with your own invite code.');
    }

    final partnerIntake = await getPartnerTodayIntake(partnerProfile.id);

    if (_isLive && currentUserId.isNotEmpty) {
      try {
        final client = _supabaseService!.client;

        // 1. Check if a pair already exists between these two users in either direction
        final existingPairs = await client
            .from('friend_synergy_pairs')
            .select()
            .or('and(user_a_id.eq.$currentUserId,user_b_id.eq.${partnerProfile.id}),and(user_a_id.eq.${partnerProfile.id},user_b_id.eq.$currentUserId)')
            .limit(1);

        Map<String, dynamic> pairRecord;

        if (existingPairs.isNotEmpty) {
          // Reactivate existing pair
          final existing = existingPairs.first;
          final pairId = existing['id'];

          // Deactivate any other active pairs for currentUserId (strict 1-on-1)
          await client
              .from('friend_synergy_pairs')
              .update({'status': 'disconnected'})
              .or('user_a_id.eq.$currentUserId,user_b_id.eq.$currentUserId')
              .neq('id', pairId);

          pairRecord = await client
              .from('friend_synergy_pairs')
              .update({
                'status': 'active',
                'last_synced_date': DateTime.now().toIso8601String().split('T').first,
              })
              .eq('id', pairId)
              .select()
              .single();
        } else {
          // Deactivate any previous active pairs for currentUserId (strict 1-on-1)
          await client
              .from('friend_synergy_pairs')
              .update({'status': 'disconnected'})
              .or('user_a_id.eq.$currentUserId,user_b_id.eq.$currentUserId')
              .eq('status', 'active');

          // Insert new active pair
          pairRecord = await client
              .from('friend_synergy_pairs')
              .insert({
                'user_a_id': currentUserId,
                'user_b_id': partnerProfile.id,
                'status': 'active',
                'streak_count': 1,
                'theme_key': 'love',
                'last_synced_date': DateTime.now().toIso8601String().split('T').first,
              })
              .select()
              .single();
        }

        final pair = SynergyPairModel.fromJson(pairRecord, currentUserId: currentUserId).copyWith(
          partnerProfile: partnerProfile,
          partnerTodayIntakeMl: partnerIntake,
        );
        _localActivePair = pair;
        return pair;
      } catch (e) {
        debugPrint('⚠️ Error connecting live synergy pair: $e');
        throw Exception('Failed to connect partner: ${e.toString()}');
      }
    }

    // Local in-memory creation for offline/dev
    final localPair = SynergyPairModel(
      id: 'pair-local-${DateTime.now().millisecondsSinceEpoch}',
      userAId: currentUserId,
      userBId: partnerProfile.id,
      status: 'active',
      streakCount: 1,
      themeKey: 'love',
      partnerProfile: partnerProfile,
      partnerTodayIntakeMl: partnerIntake,
    );
    _localActivePair = localPair;
    return localPair;
  }

  @override
  Future<void> disconnectPartner({required String pairId}) async {
    _localActivePair = null;

    if (_isLive && pairId.isNotEmpty) {
      try {
        await _supabaseService!.client
            .from('friend_synergy_pairs')
            .update({'status': 'disconnected'})
            .eq('id', pairId);
      } catch (e) {
        debugPrint('⚠️ Error disconnecting partner: $e');
      }
    }
  }

  @override
  Future<SynergyNudgeModel> sendNudge({
    required String senderId,
    required String receiverId,
    required SynergyNudgeType nudgeType,
    String? message,
  }) async {
    final now = DateTime.now();
    final defaultMsg = message ?? 'Hey! Here is a reminder from your 1-on-1 synergy partner 💧';

    if (_isLive && senderId.isNotEmpty && receiverId.isNotEmpty) {
      try {
        final response = await _supabaseService!.client.from('synergy_nudges').insert({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'nudge_type': nudgeType.dbValue,
          'message': defaultMsg,
          'is_read': false,
          'created_at': now.toIso8601String(),
        }).select().single();

        final nudge = SynergyNudgeModel.fromJson(response);
        _localNudges.insert(0, nudge);
        return nudge;
      } catch (e) {
        debugPrint('⚠️ Error sending live nudge: $e');
      }
    }

    final localNudge = SynergyNudgeModel(
      id: 'nudge-${now.millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      nudgeType: nudgeType,
      message: defaultMsg,
      createdAt: now,
    );
    _localNudges.insert(0, localNudge);
    return localNudge;
  }

  @override
  Future<List<SynergyNudgeModel>> getRecentNudges(String userId) async {
    if (_isLive && userId.isNotEmpty) {
      try {
        final response = await _supabaseService!.client
            .from('synergy_nudges')
            .select()
            .or('receiver_id.eq.$userId,sender_id.eq.$userId')
            .order('created_at', ascending: false)
            .limit(20);

        return (response as List<dynamic>)
            .map((json) => SynergyNudgeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ Error fetching nudges: $e');
      }
    }

    return _localNudges;
  }

  @override
  Future<int> getPartnerTodayIntake(String partnerId) async {
    if (partnerId.trim().isEmpty) return 0;

    final now = DateTime.now();
    final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final startOfDayLocal = DateTime(now.year, now.month, now.day);
    final endOfDayLocal = startOfDayLocal.add(const Duration(days: 1));
    final startUtc = startOfDayLocal.toUtc().toIso8601String();
    final endUtc = endOfDayLocal.toUtc().toIso8601String();

    if (_isLive) {
      try {
        final response = await _supabaseService!.client
            .from('hydration_logs')
            .select('amount_ml')
            .eq('user_id', partnerId)
            .or('log_date.eq.$dateStr,and(log_date.is.null,logged_at.gte.$startUtc,logged_at.lt.$endUtc)');

        int total = 0;
        for (final row in (response as List<dynamic>)) {
          total += (row['amount_ml'] as num?)?.toInt() ?? 0;
        }
        return total;
      } catch (e) {
        debugPrint('⚠️ Error fetching partner today intake: $e');
      }
    }

    // Fallback: check HydrationRepository if registered (e.g. offline/mock)
    if (_hydrationRepository != null) {
      return _hydrationRepository.getTodayTotalMl(partnerId);
    }

    return 0;
  }

  @override
  Future<List<PartnerWaterLog>> getPartnerTodayWaterLogs(String partnerId) async {
    if (partnerId.trim().isEmpty) return [];

    final now = DateTime.now();
    final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final startOfDayLocal = DateTime(now.year, now.month, now.day);
    final endOfDayLocal = startOfDayLocal.add(const Duration(days: 1));
    final startUtc = startOfDayLocal.toUtc().toIso8601String();
    final endUtc = endOfDayLocal.toUtc().toIso8601String();

    if (_isLive) {
      try {
        final response = await _supabaseService!.client
            .from('hydration_logs')
            .select('id, amount_ml, beverage_type, logged_at')
            .eq('user_id', partnerId)
            .or('log_date.eq.$dateStr,and(log_date.is.null,logged_at.gte.$startUtc,logged_at.lt.$endUtc)')
            .order('logged_at', ascending: false);

        return (response as List<dynamic>).map((row) {
          final dt = DateTime.tryParse(row['logged_at']?.toString() ?? '')?.toLocal() ?? DateTime.now();
          final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
          final minute = dt.minute.toString().padLeft(2, '0');
          final amPm = dt.hour >= 12 ? 'PM' : 'AM';
          final timeStr = 'Today, $hour:$minute $amPm';

          return PartnerWaterLog(
            id: row['id']?.toString() ?? '',
            timeStr: timeStr,
            amountMl: (row['amount_ml'] as num?)?.toInt() ?? 0,
            label: row['beverage_type']?.toString() ?? 'Pure Water',
          );
        }).toList();
      } catch (e) {
        debugPrint('⚠️ Error fetching partner today water logs: $e');
      }
    }

    return [];
  }

  @override
  Future<List<PartnerDayRecord>> getPartnerPastDays(String partnerId, int goalMl) async {
    if (partnerId.trim().isEmpty) return [];

    final now = DateTime.now();
    final records = <PartnerDayRecord>[];

    for (int i = 1; i <= 3; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayLabel = i == 1 ? 'Yesterday' : (i == 2 ? '2 Days Ago' : '3 Days Ago');

      int dayIntake = 0;
      if (_isLive) {
        try {
          final response = await _supabaseService!.client
              .from('hydration_logs')
              .select('amount_ml')
              .eq('user_id', partnerId)
              .eq('log_date', dateStr);

          for (final row in (response as List<dynamic>)) {
            dayIntake += (row['amount_ml'] as num?)?.toInt() ?? 0;
          }
        } catch (e) {
          debugPrint('⚠️ Error fetching partner past day $dateStr: $e');
        }
      }

      records.add(PartnerDayRecord(
        dayLabel: dayLabel,
        dateStr: '${date.month}/${date.day}',
        intakeMl: dayIntake,
        goalMl: goalMl > 0 ? goalMl : 2600,
        isReached: goalMl > 0 && dayIntake >= goalMl,
      ));
    }

    return records;
  }

  @override
  RealtimeChannel? subscribeToPartnerUpdates({
    required String currentUserId,
    required String partnerId,
    required void Function(int intakeMl) onPartnerWaterLogged,
    required void Function(SynergyNudgeModel nudge) onNudgeReceived,
  }) {
    if (!_isLive || currentUserId.isEmpty || partnerId.isEmpty) {
      return null;
    }

    try {
      final channelName = 'partner_sync_${currentUserId}_$partnerId';
      final channel = _supabaseService!.client.channel(channelName);

      // Listen for partner's water logs (inserts, updates, deletes)
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'hydration_logs',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: partnerId,
        ),
        callback: (payload) async {
          debugPrint('🔔 Realtime: Partner water log changed! Updating live intake...');
          final total = await getPartnerTodayIntake(partnerId);
          onPartnerWaterLogged(total);
        },
      );

      // Listen for incoming nudges from partner
      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'synergy_nudges',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'receiver_id',
          value: currentUserId,
        ),
        callback: (payload) {
          debugPrint('🔔 Realtime: Received partner nudge!');
          final newRecord = payload.newRecord;
          if (newRecord.isNotEmpty) {
            final nudge = SynergyNudgeModel.fromJson(newRecord);
            onNudgeReceived(nudge);
          }
        },
      );

      channel.subscribe();
      return channel;
    } catch (e) {
      debugPrint('⚠️ Error establishing Realtime partner subscription: $e');
      return null;
    }
  }
}

