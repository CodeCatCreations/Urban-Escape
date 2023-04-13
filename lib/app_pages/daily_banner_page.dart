import 'package:flutter/material.dart';

class ProgressBannerBar {
  // Define a static method named show that takes in a BuildContext and a String message
  static void show(BuildContext context, String message) {
    // Create a SnackBar with the given message and background color
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
