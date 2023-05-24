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
    final results =
        await conn.query('SELECT id, name, latitude, longitude FROM parks');
    await conn.close();
    
    if (results.isEmpty) {
      return [];
    }

    return results
        .map((row) => {
              'id': row['id'],
              'name': row['name'],
              'latitude': row['latitude'],
              'longitude': row['longitude']
            })
        .toList();
  }

  Future<Map<int, List<Map<String, dynamic>>>>
      fetchHighNoisePollutionPolygons() async {
    final conn = await getConnection();
    final results = await conn.query('''
    SELECT p.id, c.latitude, c.longitude
    FROM high_pollution_polygons p
    INNER JOIN high_pollution_coordinates c ON p.id = c.polygon_id
    ORDER BY p.id, c.id
  ''');
    await conn.close();
    final polygons = <int, List<Map<String, dynamic>>>{};
    int currentId = 0; // initialize to a default value
    for (final row in results) {
      final id = row['id'] as int;
      final latitude = row['latitude'] as double;
      final longitude = row['longitude'] as double;
      if (currentId != id) {
        currentId = id;
        polygons[id] = [];
      }
      polygons[id]?.add({'latitude': latitude, 'longitude': longitude});
    }
    return polygons;
  }

  Future<Map<int, List<Map<String, dynamic>>>>
      fetchEcoSignificantAreasPolygons() async {
    final conn = await getConnection();
    final results = await conn.query('''
    SELECT e.id, c.latitude, c.longitude
    FROM esbopolygons e
    INNER JOIN esbocoordinates c ON e.id = c.esbopolygon_id
    ORDER BY e.id, c.id
  ''');
    await conn.close();
    final esbopolygons = <int, List<Map<String, dynamic>>>{};
    int currentId = 0; // initialize to a default value
    for (final row in results) {
      final id = row['id'] as int;
      final latitude = row['latitude'] as double;
      final longitude = row['longitude'] as double;
      if (currentId != id) {
        currentId = id;
        esbopolygons[id] = [];
      }
      esbopolygons[id]?.add({'latitude': latitude, 'longitude': longitude});
    }
    return esbopolygons;
  }
}
