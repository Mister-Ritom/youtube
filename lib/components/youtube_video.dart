import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube/models/user.dart';
import 'package:youtube/models/video.dart';

class YoutubeVideo extends StatefulWidget {
  final Video video;
  final BuildContext context;
  const YoutubeVideo({super.key, required this.video,required this.context});

  @override
  State<YoutubeVideo> createState() => _YoutubeVideoState();
}

class _YoutubeVideoState extends State<YoutubeVideo> {
  String getTime() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final durationMilli = currentTime - widget.video.uploadTime;
    var text = "";
    if (durationMilli>=1000) {
      final seconds = (durationMilli/1000).round();
      if (seconds>=60){
        final minutes  = (seconds/60).round();
        if (minutes>=60) {
          final hours  = (minutes/60).round();
          print("Hours $hours");
          if (hours>=24) {
            var days = hours/24;
            text = "$days days"; //More can be added
          }
          else {
            text = "$hours hours";
          }
        }
        else {
          text = "$minutes minutes";
        }
      }
      else {
        text =  "$seconds seconds";
      }
    }
    return text;
  }

  UserModel? user;

  void getUploader()async {
    final userDoc = await FirebaseFirestore.instance.collection("users")
        .doc(widget.video.ownerId).get();
    setState(() {
      user = UserModel.fromJson(userDoc.data()!);
    });
  }

  @override
  void initState() {
    getUploader();
    super.initState();
  }

  Widget buildBottomWidget() {
    const detailsTextStyle = TextStyle(fontSize: 10,color: Colors.grey);

    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Text(widget.video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Text(user?.name??"",style: detailsTextStyle,),
              const SizedBox(width: 8,),
              Text("${widget.video.views} views",style: detailsTextStyle,),
              const SizedBox(width: 8,),
              Text("${getTime()} ago",style: detailsTextStyle,)
            ],
          )
        ],
      ),
    );
  }

  void _openMenu() {

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.only(left: 16,right: 16),
        child: InkWell(
          child:
          Stack(
            children: [
              Image.network(widget.video.thumbnail),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: buildBottom(context),
              )
            ],
          )
          ,
        ),
      ),
    );
  }

  Container buildBottom(BuildContext context) {
    return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(150)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      foregroundImage: NetworkImage(user?.profileImage??""),
                      backgroundColor: Theme.of(context).colorScheme.inverseSurface.withAlpha(30),
                      radius: 20,
                    ),
                    buildBottomWidget(),
                    IconButton(
                        onPressed: _openMenu,
                        icon: Icon(Icons.more_vert_outlined,
                          color: Theme.of(context).colorScheme.inverseSurface,),
                    )
                  ],
                ),
              );
  }
}