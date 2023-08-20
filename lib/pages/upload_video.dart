import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:youtube/components/detailed_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/video.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UploadPageState();
  }

}
class _UploadPageState extends State<UploadPage> {

  File? videoFile;
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;
  var _startedUploading = false;

  String title = "",description = "",downloadLink = "";

  User getCurrentUser() {
    return FirebaseAuth.instance.currentUser!; //Null is not possible
  }

  Future getFile() async {
    try {

      final picker = ImagePicker();
      final file = await picker.pickVideo(source: ImageSource.gallery);
      if(file!=null) {
        videoFile = File(file.path);
        if (videoFile!=null) {
          _controller = VideoPlayerController.file(videoFile!);

          // Initialize the controller and store the Future for later use.
          setState(() {
            _initializeVideoPlayerFuture = _controller.initialize();
          });

          // Use the controller to loop the video.
          _controller.play();
          _controller.setLooping(true);
        }
        else {
          throw Exception("File is non null but Video file from path is null");
        }
      }
      else {
        throw Exception("Video file can not be null");
      }
    }
    catch(e,stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      Navigator.pop(context);
    }

  }

  @override
  void initState() {
    if (videoFile==null) {
      getFile();
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> uploadThumbnail(String videoId)async {
    if(_thumbnail!=null) {
      final DateTime now = DateTime.now();
      final int millSeconds = now.millisecondsSinceEpoch;
      final userId = getCurrentUser().uid;
      final storageRef = FirebaseStorage.instance.ref("thumbnails/$userId/$videoId/$millSeconds");
      try {
        await storageRef.putData(_thumbnail!);
        return await storageRef.getDownloadURL();
      }
      catch(e,stack) {
        storageRef.delete();
        FirebaseCrashlytics.instance.recordError(e, stack);
        Navigator.pop(context);
      }
    }
    return "";
  }

  void uploadVideoFireStore() async {
    try {
      final userId = getCurrentUser().uid;
      final DateTime now = DateTime.now();
      final int millSeconds = now.millisecondsSinceEpoch;
      final thumbnailLink = await uploadThumbnail(millSeconds.toString());
      final video = Video(ownerId: userId,
          id: millSeconds.toString(),title: title,description: description,
          thumbnail: thumbnailLink, privacy: VideoPrivacy.public,uploadTime: millSeconds);

      CollectionReference videosCollection = FirebaseFirestore.instance
          .collection('user_videos')
          .doc(userId)
          .collection("videos");

      videosCollection.doc(millSeconds.toString()).set(video.toJson()).then((value) =>
          Navigator.pop(context)
      );


    } catch (e,stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
    }
  }

  void uploadVideoStorage() async {
    if(videoFile!=null) {
      setState(() {
        _startedUploading = true;
      });
      _controller.dispose();
      final DateTime now = DateTime.now();
      final int millSeconds = now.millisecondsSinceEpoch;
      final userId = getCurrentUser().uid;
      final storageRef = FirebaseStorage.instance.ref("videos/$userId/$millSeconds");
      try {
        await storageRef.putFile(videoFile!);
        downloadLink = await storageRef.getDownloadURL();
      }
      catch(e,stack) {
        storageRef.delete();
        FirebaseCrashlytics.instance.recordError(e, stack);
        Navigator.pop(context);
      }
    }
  }

  void _onTitleChange(String newTitle) {
    title = newTitle;
  }

  void _addDescription() {

  }

  void _changeVisibility() {

  }

  Uint8List? _thumbnail;

  void pickThumb() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file!=null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _thumbnail = bytes;
      });

    }
  }

  void _getThumbnailImage() async {
    if (kIsWeb) {
      pickThumb();
    }
    else {
      if (videoFile!=null&&_thumbnail==null) {
        final newThumbnail = await VideoThumbnail.thumbnailData(
          video: videoFile!.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 75,
        );
        setState(() {
          _thumbnail = newThumbnail;
        });
      }
      else {
        pickThumb();
      }
    }
  }

  Widget getThumbnail() {
    if (kIsWeb&&_thumbnail==null) {
      return ElevatedButton(onPressed: _getThumbnailImage,
          child: const Text("Upload thumbnail"));
    }
    else {
      if (_thumbnail==null) {
        _getThumbnailImage();
      }
      return IconButton(onPressed: _getThumbnailImage, icon: _thumbnail == null
          ? const Icon(Icons.add)
          : Image.memory(_thumbnail!),);
    }
  }

  Widget geTitleAndThumb() {
    return SizedBox(
      height: 156,
      child: Row(
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child:getThumbnail(),
          ),
          SizedBox(
            width: 230,
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Title",style: Theme.of(context).textTheme.headlineSmall,),
                TextField(
                  onChanged: _onTitleChange,
                  decoration: const InputDecoration(
                    labelText: "Caption",
                    hintText: "Caption your video"
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildPlayer() {
    return Column(
      children: [
      FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the video.
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            // Use the VideoPlayer widget to display the video.
            child: VideoPlayer(_controller),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ), Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(onPressed: uploadVideoStorage, child: const Text("Upload")),
          ),
        )
      ],
    );
  }

  Widget getBody() {
    if (_startedUploading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          geTitleAndThumb(),
          SizedBox(
            width: 250,
            child: ElevatedButton(onPressed: _addDescription,
            child: const Text("Add description")),
          ),
          CustomButton(startIcon: Icons.lock, label: "Visibility",
              value: "Public", onPressed: _changeVisibility),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(onPressed: uploadVideoFireStore,child: const Text("Upload video"),),
          )

        ],
      );
    }
    else {
      if (_initializeVideoPlayerFuture!=null) {
        return buildPlayer();

      }
      else {
        return const Text("Getting video");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:false,
        title: const Text("Upload a new video"),
        actions: [
          IconButton(onPressed: uploadVideoFireStore, icon: const Icon(Icons.done))
        ],
      ),
      body: getBody()
    );
  }

}