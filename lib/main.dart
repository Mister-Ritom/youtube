import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:youtube/pages/youtube_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(
    const YoutubeApp()
  );
}

class YoutubeApp extends StatelessWidget {
  const YoutubeApp({super.key});

  final bottomNavTheme = const BottomNavigationBarThemeData(
    showUnselectedLabels: false,
    selectedLabelStyle: TextStyle(fontSize: 14),
    type: BottomNavigationBarType.fixed,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "YoutubeApp",
      theme: ThemeData.light(useMaterial3: true).copyWith(
          bottomNavigationBarTheme: bottomNavTheme
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          bottomNavigationBarTheme: bottomNavTheme
      ),
      home: const YoutubePage(),
    );
  }
}
