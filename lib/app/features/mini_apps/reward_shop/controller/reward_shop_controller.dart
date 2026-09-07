import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Hosts the bundled Vue app. This storage bridge is exclusively for demo data;
/// it never calls the wallet SDK or handles wallet credentials.
class RewardShopController extends BaseController {
  static const assetPath = 'assets/mini_apps/reward_shop/index.html';
  static const storageKey = 'reward_shop_demo_v1';
  final error = ''.obs;
  final ready = false.obs;
  WebViewController? webView;
  Timer? _loadTimeout;

  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void onInit() {
    super.onInit();
    if (supported) unawaited(load());
  }

  Future<void> load() async {
    error.value = '';
    ready.value = false;
    _loadTimeout?.cancel();
    _loadTimeout = Timer(const Duration(seconds: 20), () {
      if (!isClosed && !ready.value) {
        error.value = 'The shop took too long to open. Please try again.';
      }
    });
    try {
      final view = WebViewController();
      await view.setJavaScriptMode(JavaScriptMode.unrestricted);
      await view.addJavaScriptChannel(
        'RewardShopHost',
        onMessageReceived: (message) =>
            unawaited(_handleMessage(message.message)),
      );
      await view.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (isClosed) return;
            ready.value = true;
            _loadTimeout?.cancel();
          },
          onWebResourceError: (failure) {
            if (!isClosed && failure.isForMainFrame == true) {
              error.value = 'Could not open Reward Shop. Please try again.';
              _loadTimeout?.cancel();
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            return uri != null &&
                    uri.scheme == 'file' &&
                    uri.path.endsWith('/$assetPath')
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      );
      webView = view;
      await view.loadFlutterAsset(assetPath);
    } catch (_) {
      if (!isClosed) {
        error.value =
            'Reward Shop could not load. Rebuild the bundled mini-app and try again.';
      }
      _loadTimeout?.cancel();
    }
  }

  Future<void> _handleMessage(String raw) async {
    String? id;
    try {
      if (raw.length > 500000) throw const FormatException('Message too large');
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      if (decoded['id'] is! String) return;
      id = decoded['id'] as String;
      final prefs = await SharedPreferences.getInstance();
      switch (decoded['action']) {
        case 'read':
          await _reply(id, value: prefs.getString(storageKey));
        case 'write':
          final value = decoded['value'];
          if (value is! String) {
            throw const FormatException('Invalid demo data');
          }
          final state = jsonDecode(value);
          if (state is! Map<String, dynamic> ||
              state['version'] != 1 ||
              state['balance'] is! int ||
              (state['balance'] as int) < 0 ||
              (state['balance'] as int) > 1250 ||
              state['history'] is! List) {
            throw const FormatException('Invalid demo state');
          }
          if (!await prefs.setString(storageKey, value)) {
            throw StateError('Storage unavailable');
          }
          await _reply(id);
        default:
          await _reply(id, errorMessage: 'Unsupported shop action.');
      }
    } catch (_) {
      if (id != null) {
        await _reply(
          id,
          errorMessage: 'Could not access demo storage. Please try again.',
        );
      }
    }
  }

  Future<void> _reply(String id, {String? value, String? errorMessage}) async {
    if (isClosed) return;
    final payload = jsonEncode({
      'id': id,
      'value': value,
      'error': errorMessage,
    });
    try {
      await webView?.runJavaScript('window.rewardShopReply($payload);');
    } catch (_) {
      // The view may have been closed while a storage operation completed.
    }
  }

  @override
  void onClose() {
    _loadTimeout?.cancel();
    super.onClose();
  }
}
