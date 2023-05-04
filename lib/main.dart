import 'package:flutter/material.dart';
import 'package:urban_escape_application/app_front_page/app_screen.dart';
import 'package:urban_escape_application/database/local_user.dart';

void main() {
  runApp(const UrbanEscape());
}

class UrbanEscape extends StatelessWidget {
  const UrbanEscape({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = LocalUser();
    user.loadData();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urban Escape',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AppScreen(), //Is the main screen of the app
    );
  }
}
