import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as auth_ui;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart' as auth_google;
import 'package:flutter/material.dart';
import 'package:youtube/nav_pages/home.dart';
import 'package:youtube/nav_pages/library.dart';
import 'package:youtube/nav_pages/notifications.dart';
import 'package:youtube/nav_pages/subscriptions.dart';
import 'package:youtube/pages/upload_video.dart';
import 'package:youtube/pages/channel_page.dart';

import '../models/user.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key});

  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {

  var _index = 0;
  StatefulWidget _currentBody = const HomePage();

  late UserModel newUser;

  Future<void> checkAndCreateUser(User user) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');

    // Check if the user document already exists
    final userDoc = await usersCollection.doc(user.uid).get();

    if (!userDoc.exists) {
      String newName = user.displayName?? user.email!.split("@")[0];
      newUser = UserModel(id: user.uid, name: newName, username: user.uid, email: user.email!,
          profileImage: user.photoURL);
      await usersCollection.doc(user.uid).set(newUser.toJson());
    }
    else {
      final data = userDoc.data();
      if (data!=null) {
        newUser = UserModel.fromJson(data);
      }
      else {
        throw Exception("User Doc exists but data is null");
      }
    }
  }

  Future<String> onState() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser!=null) {
        await checkAndCreateUser(firebaseUser);
      }
    }
    catch(e,stacktrace) {
      FirebaseCrashlytics.instance.recordError(e,stacktrace);
    }
    return "Done";
  }

  void _changeIndex(int newIndex) {
    setState(() {
      _index = newIndex;
      if (newIndex == 2) {
        _index = 0;
        showModalBottomSheet(context: context, builder: buildUploadButton);
      }
      else if (newIndex == 4) {
        _currentBody = pages[3];
      }
      else {
        _currentBody = pages[newIndex];
      }
    });
  }

  Widget buildUploadItem(BuildContext context,IconData icon, String text, void Function() onPress) {
    return InkWell(
      onTap: ()=> {
        Navigator.pop(context),
        onPress()
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.outline)
              ),
              child: Icon(icon,size: 32,),
            ),
            const SizedBox(width: 16,),
            Text(text,style: const TextStyle(fontSize: 24),),
          ],
        ),
      ),
    );
  }

  void onUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UploadPage()),
    );
  }

  void onCreatePost() {

  }

  Widget buildUploadButton(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Create"),
              IconButton(onPressed: () => { Navigator.pop(context)},
                  icon: const Icon(Icons.close))
            ],
          ),
          buildUploadItem(context,Icons.arrow_upward_outlined, "Upload a video", onUpload),
          buildUploadItem(context,Icons.edit_square, "Create a post", onCreatePost),
        ],
      ),
    );
  }

  final pages = [
    const HomePage(),
    const NotificationPage(),
    const SubscriptionPage(),
    const LibraryPage(),
  ];

  final nav = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    const BottomNavigationBarItem(
        icon: Icon(Icons.notifications), label: "Notifications"),
    const BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add post"),
    const BottomNavigationBarItem(
        icon: Icon(Icons.subscriptions), label: "Subscriptions"),
    const BottomNavigationBarItem(
        icon: Icon(Icons.video_library), label: "Library")
  ];

  void gotoCurrentUser() {
    Navigator.push(
      context,
        MaterialPageRoute(builder: (context) =>
          ChannelPage(user: newUser))
      );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return auth_ui.SignInScreen(
            providers: [
              auth_ui.EmailAuthProvider(),
              auth_google.GoogleProvider(
                  clientId: "895734210430-uc47lqjp40uo1ip4dudnim2skn1uhnop.apps.googleusercontent.com"),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/Youtube.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome back, Just sign in please')
                    : const Text('Still not a user, sign up now.'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/Youtube.png'),
                ),
              );
            },
          );
        }
        else {
          return FutureBuilder(
            future: onState(),
            builder: (futureContext,snapshot){
              if (!snapshot.hasData) {
                return SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Creating user data",style: Theme.of(context).textTheme.bodyLarge,),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              }
                return Scaffold(
                    appBar: AppBar(
                      title: const Text("Youtube", textAlign: TextAlign.center,),
                      leading: const Center(
                        child: Image(image:
                        AssetImage('assets/Youtube.png'),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: InkWell(
                            onTap: gotoCurrentUser,
                            child: const UserAvatar(size: 48,),
                          ),
                        )
                      ],
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      items: nav,
                      currentIndex: _index,
                      onTap: _changeIndex,
                      iconSize: 20,
                    ),
                    body: _currentBody
                );
          });
        }
      },
    );
  }
}