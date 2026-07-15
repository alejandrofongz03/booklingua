import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/utils/logger.dart';
import 'di/injection_container.dart';
import 'services/notifications/notification_service.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    await initDependencies();
  } catch (e, stackTrace) {
    AppLogger.fatal('Failed to initialize app', error: e, stackTrace: stackTrace);
  }

  sl<NotificationService>().initialize();

  runApp(const BookLinguaApp());
}
