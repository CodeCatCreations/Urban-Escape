import 'package:flutter/material.dart';

class AchievementPage extends StatelessWidget {

  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement page'),
      ),
      body: ListView(
        // Add padding to the list view
        padding: const EdgeInsets.all(16.0),
        children: [
          GestureDetector(
            onTap: () => _showAchievementDetails(context, 'NatureLover', 'Description of NatureLover achievement'),
            child: Card(
              child: ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.nature,
                      color: Colors.green[400],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Level 1',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                title: const Text(
                  'Nature-Lover',
                  style: TextStyle(
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
                            value: 0.8,
                            backgroundColor: Colors.grey[200]!,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green[400]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text('${(100-(0.8*100)).toStringAsFixed(0)}% left'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showAchievementDetails(context, 'Goal-oriented', 'Set a goal to reach level 1'),
            child: Card(
              child: ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag,
                      color: Colors.blue[400],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Level 0',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                title: const Text(
                  'Setting Goals',
                  style: TextStyle(
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
                            value: 0.8,
                            backgroundColor: Colors.grey[200]!,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green[400]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text('${(100-(0.8*100)).toStringAsFixed(0)}% left'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
          onTap: () => _showAchievementDetails(context, 'Streak', 'Maintain a five-day streak!'),
          child: Card(
          child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.deepOrange[400],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Level 0',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              title: const Text(
                'Streak',
                style: TextStyle(
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
                          value: 0.8,
                          backgroundColor: Colors.grey[200]!,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green[400]!,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text('${(100-(0.8*100)).toStringAsFixed(0)}% left'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
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