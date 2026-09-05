import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/models/synergy_models.dart';
import 'package:infinity_wellness/app/data/repositories/user_repository.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
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
  })  : _supabaseService = supabaseService ?? (Get.isRegistered<SupabaseService>() ? SupabaseService.to : null),
        _userRepository = userRepository ?? UserRepositoryImpl();

  final SupabaseService? _supabaseService;
  final UserRepository _userRepository;

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
            .maybeSingle();

        if (response != null) {
          final pair = SynergyPairModel.fromJson(response, currentUserId: userId);
          final partnerId = pair.getPartnerId(userId);

          final partnerProfile = await _userRepository.getUserProfile(partnerId);
          final partnerIntake = await getPartnerTodayIntake(partnerId);

          _localActivePair = pair.copyWith(
            partnerProfile: partnerProfile,
            partnerTodayIntakeMl: partnerIntake,
          );
          return _localActivePair;
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
    final partnerProfile = await _userRepository.findUserByInviteCode(inviteCode);
    if (partnerProfile == null) {
      throw Exception('No user found with invite code "$inviteCode". Please verify with your partner.');
    }

    if (partnerProfile.id == currentUserId) {
      throw Exception('You cannot pair with your own invite code.');
    }

    final partnerIntake = await getPartnerTodayIntake(partnerProfile.id);

    if (_isLive && currentUserId.isNotEmpty) {
      try {
        final response = await _supabaseService!.client
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

        final pair = SynergyPairModel.fromJson(response, currentUserId: currentUserId).copyWith(
          partnerProfile: partnerProfile,
          partnerTodayIntakeMl: partnerIntake,
        );
        _localActivePair = pair;
        return pair;
      } catch (e) {
        debugPrint('⚠️ Error creating live synergy pair: $e');
      }
    }

    // Local in-memory creation
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
            .gte('logged_at', startUtc)
            .lt('logged_at', endUtc);

        int total = 0;
        for (final row in (response as List<dynamic>)) {
          total += (row['amount_ml'] as num?)?.toInt() ?? 0;
        }
        return total;
      } catch (e) {
        debugPrint('⚠️ Error fetching partner today intake: $e');
      }
    }

    return 0;
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

      // Listen for partner's water logs
      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'hydration_logs',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: partnerId,
        ),
        callback: (payload) async {
          debugPrint('🔔 Realtime: Partner logged water! Updating live...');
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
