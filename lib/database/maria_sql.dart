import 'package:mysql1/mysql1.dart';
import 'dart:io';

class MariaDB {
  static String host = 'mysql.dsv.su.se',
      user = 'jasa6359',
      password = 'ahhaiNeFi2qu',
      db = 'jasa6359';

  static int port = 3306;

  MariaDB();

  Future<MySqlConnection> getConnection() async {
    try {
      var settings = ConnectionSettings(
          host: host, port: port, user: user, password: password, db: db);
      return await MySqlConnection.connect(settings);
    } catch (e) {
      if (e is SocketException) {
        print(
            'SocketException occurred while connecting to MySQL database: ${e.message}');
// or you can display the error message in your app's UI, such as using a SnackBar or showDialog
      }
// re-throw the error to ensure that the calling code is aware of the error
      rethrow;
    }
  }

    //Fetch park data from MariaDB
  Future<List<Map<String, dynamic>>> fetchParks() async {
    final conn = await getConnection();
    final results = await conn.query('SELECT id, name, latitude, longitude FROM parks');
    await conn.close();
    return results.map((row) => {
      'id': row['id'],
      'name': row['name'],
      'latitude': row['latitude'],
      'longitude': row['longitude']
    }).toList();
  }

  /*

  Future<List<Map<String, dynamic>>> fetchParks() async {
    final conn = await getConnection();
    final results = await conn.query('SELECT * FROM parks');
    await conn.close(); //Have to close, due to waste of resource
    return results
        .map((row) => {
              'id': row['id'],
              'name': row['name'],
              'latitude': row['latitude'],
              'longitude': row['longitude'],
              'content': row['content'],
            })
        .toList();
  }
  */
}
