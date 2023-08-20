import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData startIcon;
  final String label;
  final String value;
  final VoidCallback onPressed;

  const CustomButton({super.key,
    required this.startIcon,
    required this.label,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8),
      ),
      child: SizedBox(
        width: 250,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(startIcon),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),),
                        Text(value),
                      ],
                    )
                  ],
                ),
                const Icon(Icons.arrow_circle_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
