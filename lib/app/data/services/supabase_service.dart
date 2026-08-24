import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find<SupabaseService>();

  late final SupabaseConfig config;
  bool isInitialized = false;

  SupabaseClient get client {
    if (!isInitialized) {
      throw StateError('Supabase is not initialized. Please check your Supabase credentials.');
    }
    return Supabase.instance.client;
  }

  GoTrueClient get auth => client.auth;

  Future<SupabaseService> init() async {
    config = await SupabaseConfig.load();

    if (!config.isConfigured) {
      debugPrint('ℹ️ Supabase credentials not configured in assets/config/supabase_config.local.json. Running with placeholder config.');
    }

    try {
      await Supabase.initialize(
        url: config.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: config.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        debug: kDebugMode,
      );
      isInitialized = true;
      debugPrint('✅ Supabase initialized successfully.');
    } catch (e) {
      debugPrint('⚠️ Supabase initialization note: $e');
      isInitialized = false;
    }

    return this;
  }
}
