

import 'package:flutter/material.dart';

class Achievement extends GestureDetector {
  final String title;
  final double percent = 0.8;
  final String description;
  final int maxLevel;
  int level = 0;
  final Icon icon;

  Achievement({
    Key? key,
    required this.title,
    required this.description,
    required this.maxLevel,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
            onTap: () => _showAchievementDetails(context, title, description),
            child: Card(
              child: ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(height: 4.0),
                    Text(
                      "Level $level",
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            // TODO: Get value from local_user
                            value: percent,
                            backgroundColor: Colors.grey[200]!,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green[400]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text('${(100-(percent*100)).toStringAsFixed(0)}% left'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
  void _showAchievementDetails(BuildContext context, String title, String description) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: const <Widget>[
            ],
          );
        },
      );
    }
}