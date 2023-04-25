import 'dart:io';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'goal_storage.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key, required this.storage}) : super(key: key);

  final GoalStorage storage;
  
  @override
  ProgressPageState createState() => ProgressPageState();
}

class ProgressPageState extends State<ProgressPage> {
  int minutes = 102;
  int _goal = 110;
  int animateDuration = 1000;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.storage.readGoal().then((value) {
      setState(() {
        _goal = value;
        if (_goal == 0) _goal = 1;
      });
    });
  }

  Future<File> _setGoal(int newGoal) {
    setState(() {
      _goal = newGoal;
    });

    return widget.storage.writeGoal(_goal);
  }

  @override
  Widget build(BuildContext context) {
    double percent = minutes / _goal;
    if (percent > 1.0) percent = 1.0;
    final TextEditingController _textEditingController = TextEditingController();

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.flag),
                      onPressed: () {
                        showDialog(
                          context: context, 
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Stack(
                                children: <Widget>[
                                  Positioned(
                                    right: -40.0,
                                    top: -40.0,
                                    child: InkResponse(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.close),
                                      ),
                                    ),
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Set your weekly goal.'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: _textEditingController,
                                            validator: (value) {
                                              if ((value != null || value!.isEmpty) && int.tryParse(value) != null) {
                                                if (int.parse(value) < 1) return 'Goal must be more than 0 minutes!';
                                                return null;
                                              } return 'Requires a number without digits.';
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            child: const Text("Submit"),
                                            onPressed: () {
                                              if (_formKey.currentState!.validate()) {
                                                _formKey.currentState!.save();
                                                _setGoal(int.parse(_textEditingController.text));
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                      },
                    ),
                    const Text(
                      'Set Goals',
                    ),
                  ],
                ),
                
                const Center(
                  child: Text(
                    'Weekly Progress',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 50.0,
                    animation: true,
                    animationDuration: animateDuration,
                    lineHeight: 20.0,
                    percent: percent,
                    center: Text((percent * 100).toString() + '%'),
                    progressColor: Colors.green,
                  ),
                ),
                Center(
                  child: Text(
                    '$minutes / $_goal minutes',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityData {
  final String day;
  final int minutes;

  const ActivityData(this.day, this.minutes);
}