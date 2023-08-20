import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/youtube_video.dart';
import '../models/video.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

}
class HomePageState extends State<HomePage> {



  Future<List<Video>> buildVideos()async {
    List<Video> videos = [];
    final currentUser = FirebaseAuth.instance.currentUser!;
    final subscribers = await FirebaseFirestore.instance.
    collection("user_videos").doc(currentUser.uid).get();
    for (String subscriberId in subscribers.data()?["user_ids"]) {
      final collection = await FirebaseFirestore.instance.
      collection("user_videos").doc(subscriberId)
          .collection("videos")
          .orderBy("uploadTime",descending: true)
          .get();
      for (DocumentSnapshot snapshot in collection.docs) {
        final data = snapshot.data() as Map<String, dynamic>;
        final video = Video.fromJson(data);
        videos.add(video);
      }
    }
    videos.shuffle();
    return videos;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: buildVideos(),
      builder: (futureContext,snapshot) {
        if (snapshot.hasError){
          return Center(child: Column(
            children: [
              const Text("Something went wrong"),
              Text("Error ${snapshot.error}"),
            ],
          ),);
        }
        if (snapshot.hasData) {
          if (snapshot.data!=null) {
            final videos = snapshot.data!;
            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (listContext,index) {
                  return YoutubeVideo(video: videos[index], context: listContext,);
                }
            );
          }
          else {
            return const Center(child: Text("Something went wrong.This should not happen"),);
          }
        }
      return const Center(child: CircularProgressIndicator(),);
    });
  }

}