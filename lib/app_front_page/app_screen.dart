import 'package:flutter/material.dart';
import 'package:urban_escape_application/app_front_page/app_center_page.dart';
import 'package:urban_escape_application/app_pages/settings_page.dart';
import '../app_pages/progress_page/progress_page.dart';
import '../app_pages/social_page.dart';
import '../app_pages/sounds_page.dart';
import '../app_pages/map_page.dart';
import '../app_pages/daily_banner_page.dart';

//Creating a stateful widget called AppScreen
class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

//Creating a state class called _AppScreenState that extens the AppScreen Widget
class _AppScreenState extends State<AppScreen> {
  bool _showProgressBar = false;
  int _currentIndex = 0;

//List containing insatnces of each page in the app
  final List<Widget> _appPages = [
    const ProgressPage(),
    const MapPage(),
    const SoundsPage(),
    const SocialPage(),
    const AppCenterPage(),
  ];

  void _tappedItem(int index) {
    setState(() {
      _currentIndex = index; //Updating the current index with the given index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //Returning a widget that contains the AppBar, the body and the BottomNavigationBar
      appBar: AppBar(
        /*
        Adding an IconButton to the AppBar's leading that toggles 
        the _showProgressBar variable when pressed and shows the ProgressBannerBar
        */
        leading: IconButton(
          onPressed: () {
            setState(() {
              _showProgressBar = !_showProgressBar;
            });
            ProgressBannerBar.show(context, 'You need 8 more minutes to achieve your daily goal');
          },
          icon: const Icon(Icons.bar_chart_sharp),
        ),
        /*
         Adding an IconButton to the AppBar's actions 
        that navigates to the SettingsPage when pressed
        */
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: ((context) => const SettingsPage())),
              );
            },
          )
        ],
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
        // backgroundColor: Colors.yellow,
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
            icon: Icon(Icons.people),
            label: 'Social',
          ),
        ],
      ),
    );
  }
}
