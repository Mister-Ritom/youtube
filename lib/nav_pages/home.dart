import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';

import '../models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

}
class HomePageState extends State<HomePage> {

  Future<void> checkAndCreateUser(User user) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');

    // Check if the user document already exists
    final userDoc = await usersCollection.doc(user.uid).get();

    if (!userDoc.exists) {
      String newName = user.displayName?? user.email!.split("@")[0];
      UserModel newUser = UserModel(id: user.uid, name: newName, username: user.uid, email: user.email!,
          profileImage: user.photoURL);
      await usersCollection.doc(user.uid).set(newUser.toJson());
    }
  }

  void onState() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser!=null) {
        await checkAndCreateUser(firebaseUser);
      }
    }
    catch(e,stacktrace) {
      FirebaseCrashlytics.instance.recordError(e,stacktrace);
    }
  }


  @override
  void initState() {
    onState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text("Dummy text")
      ],
    );
  }

}