import 'package:flutter/material.dart';

class ProgressBannerBar {
  static void show(BuildContext context, String message, {Duration duration = const Duration(seconds: 10)}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
      ),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
