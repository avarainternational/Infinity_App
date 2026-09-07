import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SupabaseConfig {
  const SupabaseConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.redirectUrl = 'io.supabase.infinitywellness://login-callback/',
  });

  static const String localAssetPath =
      'assets/config/supabase_config.local.json';
  // Fallback / default placeholder credentials
  static const String defaultUrl = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.example';
  static const String defaultRedirectUrl =
      'io.supabase.infinitywellness://login-callback/';

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String redirectUrl;

  bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('YOUR_PROJECT_REF') &&
      !supabaseAnonKey.contains('example');

  static Future<SupabaseConfig> load() async {
    // 1. Try to load local config file
    final localJson = await _tryLoadAsset(localAssetPath);
    if (localJson != null) {
      try {
        final decoded = jsonDecode(localJson) as Map<String, dynamic>;
        return SupabaseConfig.fromJson(decoded);
      } catch (e) {
        debugPrint('Failed to parse $localAssetPath: $e');
      }
    }

    // The committed example is documentation only. Loading it at runtime can
    // send users to a project they do not own or that is no longer available.
    return const SupabaseConfig(
      supabaseUrl: defaultUrl,
      supabaseAnonKey: defaultAnonKey,
      redirectUrl: defaultRedirectUrl,
    );
  }

  static Future<String?> _tryLoadAsset(String assetPath) async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (_) {
      return null;
    }
  }

  factory SupabaseConfig.fromJson(Map<String, dynamic> json) {
    return SupabaseConfig(
      supabaseUrl: (json['supabaseUrl'] ?? defaultUrl).toString().trim(),
      supabaseAnonKey: (json['supabaseAnonKey'] ?? defaultAnonKey)
          .toString()
          .trim(),
      redirectUrl: (json['redirectUrl'] ?? defaultRedirectUrl)
          .toString()
          .trim(),
    );
  }
}
