import 'package:flutter_test/flutter_test.dart';
import 'package:mysql1/mysql1.dart';
import 'package:urban_escape_application/database/maria_sql.dart';

void main() {
  group('MariaDB', () {
    late MariaDB mariaDB;

    setUp(() {
      mariaDB = MariaDB();
    });

    test('getConnection', () async {
      final MySqlConnection connection = await mariaDB.getConnection();
      expect(connection, isNotNull);

      try {
        final results = await connection.query('SELECT 1');

        // Check if the query executed successfully
        expect(results, isNotNull);
      } catch (e) {
        // Handle any exceptions that may occur during query execution
        fail('Failed to execute test query: $e');
      }      

    });

    test('fetchParks', () async {
      final List<Map<String, dynamic>> parks = await mariaDB.fetchParks();

      for (final park in parks) {
        expect(park, containsPair('id', isA<int>()));
        expect(park, containsPair('name', isA<String>()));
        expect(park, containsPair('latitude', isA<double>()));
        expect(park, containsPair('longitude', isA<double>()));
      }

      final firstPark = parks[0];
      expect(firstPark, containsPair('id', equals(1)));
      expect(firstPark, containsPair('name', 'Kungsträdgården'));
      expect(firstPark, containsPair('latitude', equals(59.33084441)));
      expect(firstPark, containsPair('longitude', equals(18.07186929)));

      final anyParkNumber = parks[26];
      expect(anyParkNumber, containsPair('id', equals(27)));
      expect(anyParkNumber, containsPair('name', 'Gustav Adolfsparken'));
      expect(anyParkNumber, containsPair('latitude', equals(59.33696482)));
      expect(anyParkNumber, containsPair('longitude', equals(18.09754998)));

      final lastPark = parks[77];
      expect(lastPark, containsPair('id', equals(78)));
      expect(lastPark, containsPair('name', 'Starboparken'));
      expect(lastPark, containsPair('latitude', equals(59.37367735)));
      expect(lastPark, containsPair('longitude', equals(17.88660444)));
    });

    test('fetchHighNoisePollutionPolygons', () async {
      final Map<int, List<Map<String, dynamic>>> polygons =
          await mariaDB.fetchHighNoisePollutionPolygons();

      for (final entry in polygons.entries) {
        final int id = entry.key;
        final List<Map<String, dynamic>> coordinates = entry.value;

        expect(id, isA<int>());
        expect(coordinates, isA<List<Map<String, dynamic>>>());

        for (final coordinate in coordinates) {
          expect(coordinate, containsPair('latitude', isA<double>()));
          expect(coordinate, containsPair('longitude', isA<double>()));
        }
      }

      final firstPolygon = polygons[1];
      expect(firstPolygon![0],
          containsPair('latitude', equals(59.36119244724035)));
      expect(firstPolygon[0],
          containsPair('longitude', equals(17.936735356416644)));

      final anyPolygon = polygons[693];
      expect(
          anyPolygon![0], containsPair('latitude', equals(59.23213987669342)));
      expect(
          anyPolygon[0], containsPair('longitude', equals(18.194524563820256)));
      expect(
          anyPolygon[5], containsPair('latitude', equals(59.23225691374435)));
      expect(
          anyPolygon[5], containsPair('longitude', equals(18.194297509884333)));

      final lastPolygon = polygons[902];
      expect(
          lastPolygon![0], containsPair('latitude', equals(59.40434484184283)));
      expect(lastPolygon[0],
          containsPair('longitude', equals(17.967253525223718)));
      expect(
          lastPolygon[1], containsPair('latitude', equals(59.40435381833244)));
      expect(lastPolygon[1],
          containsPair('longitude', equals(17.967253516562362)));
      expect(
          lastPolygon[2], containsPair('latitude', equals(59.4043627904047)));
      expect(lastPolygon[2],
          containsPair('longitude', equals(17.967235902263425)));
      expect(
          lastPolygon[3], containsPair('latitude', equals(59.40437177131161)));
      expect(
          lastPolygon[3], containsPair('longitude', equals(17.96725349923963)));
      expect(
          lastPolygon[4], containsPair('latitude', equals(59.40437177572654)));
      expect(
          lastPolygon[4], containsPair('longitude', equals(17.96727110488186)));
      expect(
          lastPolygon[5], containsPair('latitude', equals(59.404362803649526)));
      expect(
          lastPolygon[5], containsPair('longitude', equals(17.96728871917615)));
      expect(
          lastPolygon[6], containsPair('latitude', equals(59.40435382274737)));
      expect(lastPolygon[6],
          containsPair('longitude', equals(17.967271122195275)));
      expect(
          lastPolygon[7], containsPair('latitude', equals(59.40434484184283)));
      expect(lastPolygon[7],
          containsPair('longitude', equals(17.967253525223718)));
    });

    test('fetchEcoSignificantAreasPolygons', () async {
      final Map<int, List<Map<String, dynamic>>> polygons =
          await mariaDB.fetchEcoSignificantAreasPolygons();

      for (final entry in polygons.entries) {
        final int id = entry.key;
        final List<Map<String, dynamic>> coordinates = entry.value;

        expect(id, isA<int>());
        expect(coordinates, isA<List<Map<String, dynamic>>>());

        for (final coordinate in coordinates) {
          expect(coordinate, containsPair('latitude', isA<double>()));
          expect(coordinate, containsPair('longitude', isA<double>()));
        }
      }

      final firstPolygon = polygons[1];
      expect(firstPolygon![0],
          containsPair('latitude', equals(59.35217858529005)));
      expect(firstPolygon[0],
          containsPair('longitude', equals(18.045001265020026)));

      final anyPolygon = polygons[119];
      expect(anyPolygon![0], 
      containsPair('latitude', equals(59.25009752363029)));
      expect(anyPolygon[0], 
      containsPair('longitude', equals(18.105121215979967)));
      expect(anyPolygon[19], 
      containsPair('latitude', equals(59.25009752363029)));
      expect(anyPolygon[19], 
      containsPair('longitude', equals(18.105121215979967)));

      final lastPolygon = polygons[230];
      expect(lastPolygon![0], 
      containsPair('latitude', equals(59.26592354160706)));
      expect(lastPolygon[0], 
      containsPair('longitude', equals(18.063350951902613)));
      expect(lastPolygon[5], 
      containsPair('latitude', equals(59.2627422716936)));
      expect(lastPolygon[5], 
      containsPair('longitude', equals(18.070217801913394)));
      expect(lastPolygon[8], 
      containsPair('latitude', equals(59.261393180898196)));
      expect(lastPolygon[8], 
      containsPair('longitude', equals(18.074860965787025)));
      expect(lastPolygon[16], 
      containsPair('latitude', equals(59.2605568837869)));
      expect(lastPolygon[16], 
      containsPair('longitude', equals(18.077366124315677)));
      expect(lastPolygon[19], 
      containsPair('latitude', equals(59.25986592855698)));
      expect(lastPolygon[19], 
      containsPair('longitude', equals(18.076943812723556)));
      expect(lastPolygon[3], 
      containsPair('latitude', equals(59.2640456263235)));
      expect(lastPolygon[3], 
      containsPair('longitude', equals(18.06692424034415)));
    });
  });
}
