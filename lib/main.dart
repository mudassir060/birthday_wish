import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wallpaper/wallpaper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());

  await initializeService();
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'trekquest_bg',
      initialNotificationTitle: 'TrekQuest Service',
      initialNotificationContent: 'Background service running',
      foregroundServiceNotificationId: 999,
      // Ensure you have a valid small icon in drawable
      // Default is "ic_notification"
      // notificationIcon: 'ic_notification',
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "TrekQuest Service",
      content: "Background service is running",
    );
  }

  Timer.periodic(const Duration(seconds: 15), (timer) async {
    int day = DateTime.now().day;
    if (day == 9) {
      playMusic();
      setWallpaper();
    }
  });
}

void setWallpaper() async {
  List<String> images = [
    "https://firebasestorage.googleapis.com/v0/b/trekquest-65676.appspot.com/o/0.png?alt=media",
    "https://firebasestorage.googleapis.com/v0/b/trekquest-65676.appspot.com/o/1.png?alt=media",
    "https://firebasestorage.googleapis.com/v0/b/trekquest-65676.appspot.com/o/2.png?alt=media",
  ];

  final randomImage = images[Random().nextInt(images.length)];

  try {
    Stream<String> progress = Wallpaper.imageDownloadProgress(randomImage);
    progress.listen((data) {
      log("Download Progress: $data");
    }, onDone: () async {
      await Wallpaper.bothScreen(
        options: RequestSizeOptions.resizeExact,
      );
      log("Wallpaper Set!");
    });
  } catch (e) {
    log("Error setting wallpaper: $e");
  }
}

void playMusic() async {
  final player = AudioPlayer();
  try {
    await player.setAsset('assets/Desi Birthday Anthem.mp3');
    await player.setVolume(0.5);
    player.play();
  } catch (e) {
    log("Error playing audio: $e");
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('TrekQuest Background Service')),
        body: const Center(child: Text('Background service is running...')),
      ),
    );
  }
}
