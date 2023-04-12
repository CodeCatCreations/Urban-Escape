import 'package:flutter/material.dart';
import 'package:urban_escape_application/home_page.dart';

//ändra
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
