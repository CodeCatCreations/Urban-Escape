import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_pages/progress_page/progress_page.dart';
import '../app_pages/time_page/time_tracking_page.dart';
import '../app_pages/sounds_page.dart';
import '../app_pages/map_pages/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/time_data.dart';

//Creating a stateful widget called AppScreen
class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

//Creating a state class called _AppScreenState that extens the AppScreen Widget
class _AppScreenState extends State<AppScreen> {
  int _currentIndex = 0;

//List containing insatnces of each page in the app
  final List<Widget> _appPages = [
    const ProgressPage(),
    const MapPage(),
    const SoundsPage(),
    const TimeTrackingPage(),
  ];

  void _tappedItem(int index) {
    setState(() {
      _currentIndex = index; //Updating the current index with the given index
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimeData>(
      create: (context) => TimeData(),
      child: Scaffold(
        //Returning a widget that contains the AppBar, the body and the BottomNavigationBar
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Urban Escape',
            style: GoogleFonts.pacifico(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
        ),
        /*
      Creating an IndexedStack that contains the app pages and 
      updates the current index based on the tapped item
      */
        body: IndexedStack(
          index: _currentIndex,
          children: _appPages,
        ),

        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.green,
          onTap: (int index) {
            _tappedItem(index);
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Sounds',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_rounded),
              label: 'Stopwatch',
            ),
          ],
        ),
      ),
    );
  }
}
