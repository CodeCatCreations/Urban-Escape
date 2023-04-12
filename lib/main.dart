import 'package:flutter/material.dart';
import 'package:urban_escape_application/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urban Escape',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RootPage(title: 'Urban Escape Home Page'),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key, required this.title});

  final String title;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomePage(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.show_chart),
              onPressed: () {
                // Handle settings icon press
              },
            ),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                // Handle search icon press
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Handle notifications icon press
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Handle profile icon press
              },
            ),
          ],
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      */
    );
  }
}
