import 'package:flutter/material.dart';
import 'package:brainbuzz/others/color.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onPressed;

  const GradientButton({
    Key? key,
    required this.text,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("ff99ff"),
              hexStringToColor("c44dff"),
              hexStringToColor("7700b3"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(imagePath, height: 80, width: 80),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
