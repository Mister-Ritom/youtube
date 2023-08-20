import 'package:flutter/material.dart';

class UserAvatar extends StatefulWidget {
  final String? profileImage;
  final void Function() onPress;
  const UserAvatar({super.key, required this.profileImage,required this.onPress});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  @override
  Widget build(BuildContext context) {
    if (widget.profileImage==null) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
      );
    }
    else {
      return CircleAvatar(
        foregroundImage: NetworkImage(widget.profileImage!),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface.withAlpha(30),
        radius: 20,
      );
    }
  }
}