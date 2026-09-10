import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/data/services/notification_service.dart';
import 'package:infinity_wellness/app/data/services/supabase_service.dart';
import 'package:infinity_wellness/main_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<SupabaseService>(
    () => SupabaseService().init(),
    permanent: true,
  );
  await Get.putAsync<NotificationService>(
    () => NotificationService().init(),
    permanent: true,
  );
  runApp(const MyApp());
}
