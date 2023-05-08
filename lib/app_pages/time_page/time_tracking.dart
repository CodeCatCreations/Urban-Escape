import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:urban_escape_application/database/local_user.dart';

class TimeTrackingPage extends StatefulWidget {
  const TimeTrackingPage({super.key});

  @override
  State<TimeTrackingPage> createState() => _TimeTrackingPageState();
}

class _TimeTrackingPageState extends State<TimeTrackingPage> {
  int _passedTime = 0;
  double _percent = 0.0;
  int goal = 10;
  Timer _timer = Timer(Duration.zero, () {});
  bool click = true;

  Future<void> loadLastStopwatchTime() async {

    final lastTimeUserStoppedTheTime = await LocalUser.loadStopwatchTime();

    // In setState we set the state of the widget with the loaded stopwatch time and the percent of the goal achieved
    setState(() {
      _passedTime = lastTimeUserStoppedTheTime;
    
      _percent = getPercent();
    });
  }

  void saveLastStopwatchTime(int time) async {
    await LocalUser.saveStopwatchTime(time);
  }

  double getPercent() {
    // Calculate the percentage of the goal that has been reached based on the passed time.
    // If the passed time is greater than the goal, set the percentage to 1.0 (or 100%).
    // Otherwise, set the percentage to the ratio of the passed time to the goal.
    return Duration(seconds: _passedTime).inSeconds.toDouble() > (goal * 100)
            ? 1
            : Duration(seconds: _passedTime).inSeconds.toDouble() / (goal * 100);
  }

  @override
  void initState() {
    super.initState();
    loadLastStopwatchTime();
  }

  void startTimer() {
    if (_timer.isActive) return;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _passedTime++;
        _percent = getPercent();
      });
    });
  }

  void stopTimer() {
    _timer.cancel();
    // Save the current stopwatch time to shared_preferences when stopped
    saveLastStopwatchTime(_passedTime);
  }

  void resetTimer() {
    setState(() {
      _passedTime = 0;
      _percent = 0;
    });
    // Reset the saved stopwatch time in shared_preferences
  }

  String get timerText {
    Duration duration = Duration(milliseconds: _passedTime * 10);
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Colors.white],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Time Tracking',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Pacifico',
            ),
          ),
          const SizedBox(height: 20),
          CircularPercentIndicator(
            radius: 180,
            lineWidth: 20.0,
            backgroundWidth: 15,
            animation: true,
            animationDuration: 10,
            animateFromLastPercent: true,
            percent: _percent,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor:
                _percent == 1.0 ? Colors.green.shade300 : Colors.blue.shade300,
            backgroundColor: Colors.white54,
            center: Container(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    timerText,
                    style: const TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Daily progress: " + (_percent*100).toInt().toString()+"%",
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    alignment: Alignment.bottomCenter,
                    iconSize: 100,
                    onPressed: () {
                      setState(() {
                        click = !click;
                        (click == false) ? startTimer() : stopTimer();
                      });
                    },
                    icon: Icon((click == false) ? Icons.pause_circle_filled :
                    Icons.play_circle_filled, color: Colors.grey.shade50),
                  ),
                ],
              )
            )
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              ElevatedButton(
                child: const Text('Reset'),
                onPressed: () {
                  setState(() {
                    click = true;
                  });
                  resetTimer();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
           



















/*import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool _checking = true;

  final List<Person> _people = [
    Person('Sam Salmi', 'XamXalmi@example.com'),
    Person('Emily Garcia', 'emily.garcia@example.com'),
    Person('Benjamin Lee', 'benjamin.lee@example.com'),
    Person('Sophia Patel', 'sophia.patel@example.com'),
  ];

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  _checkIfLoggedIn() async {
    final accessToken = await FacebookAuth.instance.accessToken;

    setState(() {
      _checking = false;
    });

    if (accessToken != null) {
      print(accessToken.toJson());
      final userData = await FacebookAuth.instance.getUserData();
      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
    } else {
      _login();
    }
  }

  _login() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;

      final userData = await FacebookAuth.instance.getUserData();
      _userData = userData;
    } else {
      print(result.status);
      print(result.message);
    }
    setState(() {
      _checking = false;
    });
  }

  _logout() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;

    setState(() {});
  }

  void _addPerson(String name, String email) {
    setState(() {
      _people.add(Person(name, email));
    });
    Navigator.of(context).pop();
  }

  void _showAddPersonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final nameController = TextEditingController();
        final emailController = TextEditingController();

        return AlertDialog(
          title: const Text('Add a new person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter the name',
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter the email',
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  _addPerson(nameController.text, emailController.text);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonBubble(BuildContext context, Person person) {
    return Dismissible(
      key: Key(person.name),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _people.remove(person);
        });
      },
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30.0,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name),
                    const SizedBox(height: 5.0),
                    Text(person.email),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social page',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: TextButton(
          onPressed: _userData != null ? _logout : _login,
          child: Text(
            _userData != null ? 'LOG OUT' : 'LOG IN',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.blue),
            onPressed: () {
              _showAddPersonDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _people.length,
              itemBuilder: (BuildContext context, int index) {
                final person = _people[index];
                return _buildPersonBubble(context, person);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Person {
  final String name;
  final String email;

  Person(this.name, this.email);
}*/
/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool _isLoggedIn = false;
  List<dynamic>? _friends;

  @override
  void initState() {
    super.initState();
  }

  _login() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;

      final userData = await FacebookAuth.instance.getUserData();
      _userData = userData;

      final response = await http.get(Uri.parse(
          'https://graph.facebook.com/v12.0/me/friends?fields=name,picture&limit=1000&access_token=${_accessToken!.token}'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _friends = json['data'];
        });
      } else {
        print('Failed to get friends data');
      }

      setState(() {
        _isLoggedIn = true;
      });
    } else {
      print(result.status);
      print(result.message);
    }
  }

  _logout() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    _friends = null;

    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social page',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: TextButton(
          onPressed: _isLoggedIn ? _logout : _login,
          child: Text(
            _isLoggedIn ? 'LOG OUT' : 'LOG IN',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ),
      body: _isLoggedIn
          ? _friends == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _friends!.length,
        itemBuilder: (BuildContext context, int index) {
          final friend = _friends![index];
          final String name = friend['name'] ?? '';
          final String pictureUrl = friend['picture']['data']['url'] ?? '';

          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(pictureUrl)),
            title: Text(name),
          );
        },
      )
          : const Center(child: Text('Please log in to see your friends')),
    );
  }
}
*/

