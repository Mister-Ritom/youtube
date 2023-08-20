import 'package:flutter/cupertino.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return LibraryPageState();
  }

}
class LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text("Dummy text")
      ],
    );
  }

}