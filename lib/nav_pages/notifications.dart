import 'package:flutter/cupertino.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationPageState();
  }

}
class NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text("Dummy text in notifs")
      ],
    );
  }

}