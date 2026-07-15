import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/logger.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
    AppLogger.info('NotificationService initialized');
  }

  Future<void> showTranslationComplete({
    required String title,
    required String bookName,
    String? filePath,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'translation_channel',
      'Traducciones',
      channelDescription: 'Notificaciones de traducción completada',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      '$bookName ha sido traducido exitosamente.',
      details,
    );

    AppLogger.info('Notification shown for: $bookName');
  }

  Future<void> showTranslationError({
    required String bookName,
    required String error,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'translation_error_channel',
      'Errores de traducción',
      channelDescription: 'Errores durante la traducción',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Error en traducción',
      'Error al traducir $bookName: $error',
      details,
    );
  }
}
