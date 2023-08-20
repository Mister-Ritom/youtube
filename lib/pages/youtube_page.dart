import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as auth_ui;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart' as auth_google;
import 'package:flutter/material.dart';
import 'package:youtube/nav_pages/home.dart';
import 'package:youtube/nav_pages/library.dart';
import 'package:youtube/nav_pages/notifications.dart';
import 'package:youtube/nav_pages/subscriptions.dart';
import 'package:youtube/pages/upload_video.dart';
import 'package:youtube/pages/user_profile.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key});

  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {

  var _index = 0;
  StatefulWidget _currentBody = const HomePage();

  void _changeIndex(int newIndex) {
    setState(() {
      _index = newIndex;
      if (newIndex == 2) {
        _index = 0;
        showModalBottomSheet(context: context, builder: buildUploadButton);
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
          UserProfile(userId: FirebaseAuth.instance.currentUser!.uid,))
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
      },
    );
  }
}