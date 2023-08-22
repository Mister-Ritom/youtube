import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:youtube/models/user.dart';

import '../components/youtube_video.dart';
import '../models/channel.dart';
import '../models/video.dart';

class ChannelPage extends StatefulWidget {
  final UserModel user;
  const ChannelPage({super.key, required this.user});

  @override
  State<ChannelPage> createState() => _ChannelPageState();

}

class _ChannelPageState extends State<ChannelPage> {

  Future<Channel?> createChannelModel() async {
    try {
      final channelsCollection = FirebaseFirestore.instance.collection('channels');
      final channelDoc = await channelsCollection.doc(widget.user.id).get();
      if (channelDoc.exists) {
        final data = channelDoc.data();
        if (data!=null) {
          return Channel.fromJson(data);
        }
        else {
          throw Exception("Somehow channel data is null");
        }
      }
      else {
        final channel = Channel(id: widget.user.id, username: widget.user.username,
            displayName: widget.user.name, description: '');
        await channelsCollection.doc(widget.user.id).set(channel.toJson());
        return channel;
      }
    }
    catch (e,stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      Navigator.pop(context);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }
  
  void onSearch() {
    
  }
  
  void onMenu() {
    
  }

  void subscribeChannel() {

  }

  Widget buildInformation(Channel channel) {
    const informationTextStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey,
    );
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                channel.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: informationTextStyle,
              ),
              const SizedBox(width: 8,),
              const Text("1M subscribers",style: informationTextStyle,),
              const SizedBox(width: 8,),
              Text("${channel.videoCount} videos",style: informationTextStyle,)
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16,right: 16),
              child: Text(
                channel.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              )
          ),
        ],
      ),
    );
  }

  Widget buildSubscribe() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width-96,
        height: 42,
        child: ElevatedButton(
              onPressed: subscribeChannel,
              child: const Text("Subscribe")
          ),
      ),
    );
  }

  Future<List<Video>> buildVideos()async {
      final collection = await FirebaseFirestore.instance.
      collection("user_videos").doc(widget.user.id)
          .collection("videos")
          .orderBy("uploadTime",descending: true)
          .get();
      final videos = collection.docs.map((e) => Video.fromJson(e.data())).toList();
    return videos;
  }

  Widget buildHomeTab() {
    return buildVideosTab(); // TODO create a separate tab
  }

  Widget buildVideosTab() {
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
                    return YoutubeVideo(video: videos[index], context: listContext,); //Maybe create another widget
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

  Widget buildToCome() {
    return const Center(child: Text("Coming soon"),);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: createChannelModel(),
      builder: (futureContext,snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"),);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(),);
        }
        if (snapshot.data==null) {
          return const Center(child: Text("Something went wrong"),);
        }
        final channel = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(channel.username),
            actions: [
              IconButton(onPressed: onSearch, icon: const Icon(Icons.search)),
              IconButton(onPressed: onMenu, icon: const Icon(Icons.more_vert)),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Image(
                  fit: BoxFit.fill,
                  image: NetworkImage(channel.banner),
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    // If loading from the network fails, return the fallback asset
                    return const Image(image: AssetImage("assets/GradientImage.jpg"),fit: BoxFit.fill,);
                  },
                ),
              ),
              Text(channel.displayName,
                style: Theme.of(futureContext).textTheme.headlineMedium,),
              buildInformation(channel),
              buildSubscribe(),
              SizedBox(
                height: 300,
                child: DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    appBar: AppBar(
                      toolbarHeight: 0,
                      automaticallyImplyLeading:false,
                      bottom: const TabBar(
                        tabs: [
                          Tab(text:"Home"),
                          Tab(text:"Videos"),
                          Tab(text:"Playlists"),
                          Tab(text:"About"),
                        ],
                      ),
                    ),
                    body: TabBarView(
                      children: [
                        buildHomeTab(),
                        buildVideosTab(),
                        buildToCome(),
                        buildToCome(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    });
  }
}