import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'fitstart_tracker',
    'FitStart Tracker',
    description: 'Monitorando seu treino em tempo real',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'fitstart_tracker',
      initialNotificationTitle: 'TREINO ATIVO',
      initialNotificationContent: 'Iniciando cronômetro...',
      foregroundServiceTypes: [AndroidForegroundType.specialUse],
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  int segundos = 0;
  Timer? timer;

  
  service.on('resetTimer').listen((event) {
    segundos = 0;
  });

  timer = Timer.periodic(const Duration(seconds: 1), (t) async {
    segundos++;

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "FitStart: Treino em Curso",
          content: "Tempo decorrido: ${formatTime(segundos)}",
        );
      }
    }

    service.invoke('update', {"seconds": segundos});
  });

  service.on('stopService').listen((event) {
    timer?.cancel();
    service.stopSelf();
  });
}

String formatTime(int seconds) {
  int mins = seconds ~/ 60;
  int secs = seconds % 60;
  return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
}
