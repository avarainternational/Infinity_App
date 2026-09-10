import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';

/// Helper utility to normalize Supabase storage and media URLs to route through
/// the active Cloudflare proxy endpoint when running in restricted/firewalled ISP environments.
class ImageUrlHelper {
  ImageUrlHelper._();

  static const String _defaultProjectHost = 'sxbwrwvgmlklpojmokye.supabase.co';
  static const String _defaultProxyHost = 'supabase-proxy-infinity-wellness.avarainternational.workers.dev';

  /// Normalizes any Supabase media URL to use the configured proxy endpoint
  static String? normalize(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();

    // 1. If SupabaseService is registered, check if custom proxy URL is active
    if (Get.isRegistered<SupabaseService>()) {
      final configuredUrl = SupabaseService.to.config.supabaseUrl;
      if (configuredUrl.isNotEmpty && !configuredUrl.contains('YOUR_PROJECT_REF')) {
        final proxyUri = Uri.tryParse(configuredUrl);
        final uri = Uri.tryParse(trimmed);
        if (uri != null && proxyUri != null && uri.host.endsWith('.supabase.co')) {
          return uri.replace(
            scheme: proxyUri.scheme,
            host: proxyUri.host,
            port: proxyUri.hasPort ? proxyUri.port : null,
          ).toString();
        }
      }
    }

    // 2. Fallback normalization for Infinity Wellness Supabase storage
    if (trimmed.contains(_defaultProjectHost)) {
      return trimmed.replaceAll(_defaultProjectHost, _defaultProxyHost);
    }

    return trimmed;
  }
}
