import 'package:flutter/material.dart';
import 'package:music_tech/main.dart';

class Helper {
  static void showCustomSnackBar(String message,
      [Color bgColor = Colors.red, Color color = Colors.white]) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: color,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: bgColor,
    );
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
