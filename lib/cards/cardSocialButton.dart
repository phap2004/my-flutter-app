import 'package:flutter/material.dart';

GestureDetector buildSocialButton({
  required String imgPath,
  required String text,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imgPath, width: 24, height: 24),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    ),
  );
}
