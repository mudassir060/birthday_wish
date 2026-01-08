// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hbd/app/app.bottomsheets.dart';
import 'package:hbd/app/app.locator.dart';
import 'package:wallpaper/wallpaper.dart';
import 'package:just_audio/just_audio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("1");
  await setupLocator();
  // setupDialogUi();
  setupBottomSheetUi();
  runApp(const MainApp());
  background();
}

Future<void> background() async {
  final service = FlutterBackgroundService();
  print("2");
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'trekquest_bg',
      initialNotificationTitle: 'TrekQuest Service',
      initialNotificationContent: 'Background service running',
      foregroundServiceNotificationId: 999,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(service) async {
  print("3");
  DartPluginRegistrant.ensureInitialized();
  print("Runing in background");
  WidgetsFlutterBinding.ensureInitialized();

  bool isMusicPlay = true;
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    int day = DateTime.now().day;
    print("Runing in background");
    if (day == 1) {
      if (isMusicPlay == true) {
        isMusicPlay = false;
        playMusic();
      }
      setWallpaper();
    } else {
      print("else");
    }
  });
}

void setWallpaper() async {
  List<String> images = [
    "https://firebasestorage.googleapis.com/v0/b/trekquest-65676.appspot.com/o/0.png?alt=media&token=9343f286-7f6f-40cd-9bbb-d0f90bce928a",
    "https://firebasestorage.googleapis.com/v0/b/trekquest-65676.appspot.com/o/1.png?alt=media&token=7efd2132-cc0b-443e-8455-195a8322fd52",
    "https://firebasestorage.googleapis.com/v0/b/trekquest-65676.appspot.com/o/2.png?alt=media&token=1ea1af90-5d95-495c-b253-afbec5a8a5b7",
    "https://firebasestorage.googleapis.com/v0/b/trekquest-65676.appspot.com/o/3.png?alt=media&token=3cfda5b7-5776-4010-8573-2c68609b7936",
    "https://firebasestorage.googleapis.com/v0/b/trekquest-65676.appspot.com/o/4.png?alt=media&token=f4a57c3e-2e3c-4ca2-9250-e7806c709293",
  ];

  Random random = Random();
  String randomImageUrl = images[random.nextInt(images.length)];

  try {
    WidgetsFlutterBinding.ensureInitialized();
    Stream<String> progressString =
        Wallpaper.imageDownloadProgress(randomImageUrl);
    progressString.listen((data) async {
      print("DataReceived: $data");
    }, onDone: () async {
      await Wallpaper.bothScreen(
        options: RequestSizeOptions.resizeExact,
      );
      print("Task Done");
    }, onError: (error) {
      print("Some Error $error");
    });
  } catch (e) {
    print("========>$e");
  }
}

playMusic() async {
  final player = AudioPlayer();
  try {
    await player.setAsset('assets/icons/Desi Birthday Anthem.mp3');
    player.load;
    await player.setVolume(0.5);
    player.play();
  } catch (e) {
    print("Error playing audio: $e");
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // initialRoute: Routes.startupView,
      // onGenerateRoute: StackedRouter().onGenerateRoute,
      // navigatorKey: StackedService.navigatorKey,
      // navigatorObservers: [
      //   StackedService.routeObserver,
      // ],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TrekQuest Background Service'),
        ),
        body: const Center(
          child: Text('Background service is running...'),
        ),
      ),
    );
  }
}
