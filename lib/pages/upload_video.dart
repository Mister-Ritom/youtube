import 'package:flutter/material.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UploadPageState();
  }

}
class _UploadPageState extends State<UploadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload a new video"),
      ),
      body: const Column(

      ),
    );
  }

}