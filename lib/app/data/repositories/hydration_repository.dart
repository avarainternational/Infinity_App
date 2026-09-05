import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/models/hydration_log_model.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';

abstract class HydrationRepository {
  Future<HydrationLogModel> logWaterIntake({
    required String userId,
    required int amountMl,
    String beverageType = 'Pure Water',
    DateTime? loggedAt,
  });

  Future<List<HydrationLogModel>> getTodayLogs(String userId);
  Future<int> getTodayTotalMl(String userId);
  Future<List<HydrationLogModel>> getLogsForDate(String userId, DateTime date);
  Future<int> getTotalMlForDate(String userId, DateTime date);
  Future<Map<DateTime, int>> getWeeklyHistory(String userId);
  Future<void> deleteLog({required String logId, required String userId});
}

class HydrationRepositoryImpl implements HydrationRepository {
  HydrationRepositoryImpl({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? (Get.isRegistered<SupabaseService>() ? SupabaseService.to : null);

  final SupabaseService? _supabaseService;

  // Local in-memory logs fallback
  final List<HydrationLogModel> _localLogs = [];
  static int _logCounter = 0;

  bool get _isLive => _supabaseService?.isInitialized == true && _supabaseService?.config.isConfigured == true;

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Future<HydrationLogModel> logWaterIntake({
    required String userId,
    required int amountMl,
    String beverageType = 'Pure Water',
    DateTime? loggedAt,
  }) async {
    final now = loggedAt ?? DateTime.now();
    final dateStr = _formatDate(now);

    if (_isLive && userId.isNotEmpty) {
      try {
        final response = await _supabaseService!.client.from('hydration_logs').insert({
          'user_id': userId,
          'amount_ml': amountMl,
          'beverage_type': beverageType,
          'log_date': dateStr,
          'logged_at': now.toUtc().toIso8601String(),
        }).select().single();

        final log = HydrationLogModel.fromJson(response);
        _localLogs.insert(0, log);
        return log;
      } catch (e) {
        debugPrint('⚠️ Error logging intake to Supabase: $e');
      }
    }

    final localLog = HydrationLogModel(
      id: 'local-log-${now.millisecondsSinceEpoch}-${++_logCounter}',
      userId: userId,
      amountMl: amountMl,
      beverageType: beverageType,
      logDate: dateStr,
      loggedAt: now,
    );
    _localLogs.insert(0, localLog);
    return localLog;
  }

  @override
  Future<List<HydrationLogModel>> getLogsForDate(String userId, DateTime date) async {
    if (userId.trim().isEmpty) return <HydrationLogModel>[];

    final dateStr = _formatDate(date);
    final startOfDayLocal = DateTime(date.year, date.month, date.day);
    final endOfDayLocal = startOfDayLocal.add(const Duration(days: 1));
    final startOfDayUtc = startOfDayLocal.toUtc().toIso8601String();
    final endOfDayUtc = endOfDayLocal.toUtc().toIso8601String();

    if (_isLive) {
      try {
        final response = await _supabaseService!.client
            .from('hydration_logs')
            .select()
            .eq('user_id', userId)
            .or('log_date.eq.$dateStr,and(log_date.is.null,logged_at.gte.$startOfDayUtc,logged_at.lt.$endOfDayUtc)')
            .order('logged_at', ascending: false);

        final logs = (response as List<dynamic>)
            .map((json) => HydrationLogModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return logs;
      } catch (e) {
        debugPrint('⚠️ Error fetching logs for date $dateStr from Supabase: $e');
      }
    }

    // Filter local in-memory logs for the date strictly for this user
    return _localLogs.where((log) {
      final d = log.loggedAt.toLocal();
      return log.userId == userId &&
          d.year == date.year &&
          d.month == date.month &&
          d.day == date.day;
    }).toList();
  }

  @override
  Future<List<HydrationLogModel>> getTodayLogs(String userId) {
    return getLogsForDate(userId, DateTime.now());
  }

  @override
  Future<int> getTotalMlForDate(String userId, DateTime date) async {
    if (userId.trim().isEmpty) return 0;
    final logs = await getLogsForDate(userId, date);
    if (logs.isEmpty) {
      return 0;
    }
    return logs.fold<int>(0, (sum, item) => sum + item.amountMl);
  }

  @override
  Future<int> getTodayTotalMl(String userId) {
    return getTotalMlForDate(userId, DateTime.now());
  }

  @override
  Future<Map<DateTime, int>> getWeeklyHistory(String userId) async {
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final historyMap = <DateTime, int>{};

    for (int i = 0; i < 7; i++) {
      final date = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day + i);
      historyMap[date] = 0;
    }

    if (userId.trim().isEmpty) return historyMap;

    if (_isLive) {
      try {
        final startUtc = sevenDaysAgo.toUtc().toIso8601String();
        final response = await _supabaseService!.client
            .from('hydration_logs')
            .select()
            .eq('user_id', userId)
            .gte('logged_at', startUtc)
            .order('logged_at', ascending: true);

        for (final item in (response as List<dynamic>)) {
          final log = HydrationLogModel.fromJson(item as Map<String, dynamic>);
          final d = log.loggedAt.toLocal();
          final key = DateTime(d.year, d.month, d.day);
          if (historyMap.containsKey(key)) {
            historyMap[key] = (historyMap[key] ?? 0) + log.amountMl;
          }
        }
        return historyMap;
      } catch (e) {
        debugPrint('⚠️ Error fetching weekly history from Supabase: $e');
      }
    }

    // Local in-memory logs aggregation strictly for the individual user
    for (final log in _localLogs) {
      if (log.userId != userId) continue;
      final d = log.loggedAt.toLocal();
      final key = DateTime(d.year, d.month, d.day);
      if (historyMap.containsKey(key)) {
        historyMap[key] = (historyMap[key] ?? 0) + log.amountMl;
      }
    }

    return historyMap;
  }

  @override
  Future<void> deleteLog({required String logId, required String userId}) async {
    _localLogs.removeWhere((l) => l.id == logId && (userId.isEmpty || l.userId == userId));

    if (_isLive && userId.isNotEmpty) {
      try {
        await _supabaseService!.client
            .from('hydration_logs')
            .delete()
            .eq('id', logId)
            .eq('user_id', userId);
      } catch (e) {
        debugPrint('⚠️ Error deleting log from Supabase: $e');
      }
    }
  }
}
