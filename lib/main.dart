import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:youtube/nav_pages/home.dart';
import 'package:youtube/nav_pages/library.dart';
import 'package:youtube/nav_pages/notifications.dart';
import 'package:youtube/nav_pages/subscriptions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(useMaterial3: true).copyWith(
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
          )
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
          )
      ),
      home: const MyHomePage(title: 'Youtube'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var _index = 0;
  StatefulWidget _currentBody = HomePage();

  void _changeIndex(int newIndex) {
      setState(() {
        _index = newIndex;
        if(newIndex!=3){
          _currentBody = pages[newIndex];
        }
      });
  }

  final pages = [
    HomePage(),
    NotificationPage(),
    SubscriptionPage(),
    LibraryPage(),
  ];

  final nav = [
    const BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
    const BottomNavigationBarItem(icon: Icon(Icons.notifications),label: "Notifications"),
    const BottomNavigationBarItem(icon: Icon(Icons.add),label: "Add post"),
    const BottomNavigationBarItem(icon: Icon(Icons.subscriptions),label: "Subscriptions"),
    const BottomNavigationBarItem(icon: Icon(Icons.video_library),label: "Library")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,textAlign: TextAlign.center,),
        leading: const Center(
            child: Image(image:
            AssetImage('assets/Youtube.png'),
            ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(items: nav,
        currentIndex: _index,
        onTap: _changeIndex,
      ),
      body: _currentBody
    );
  }
}
