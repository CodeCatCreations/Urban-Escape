import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../database/local_user.dart';

class GoalStorage {

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/goal.txt');
  }

  Future<int> readGoal() async {
    try {
      final file = await _localFile;

      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<File> writeGoal(int goal) async {
    final file = await _localFile;
    final LocalUser localUser = LocalUser();
    localUser.setGoal();
    return file.writeAsString('$goal');
  }
}