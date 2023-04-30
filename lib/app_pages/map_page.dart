import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_escape_application/database/maria_sql.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  late GoogleMapController mapController;

  bool showParks = false;
  bool showPolygons = false;
  final Set<Marker> markers = {};
  List<Map<String, dynamic>>? parksData;

 Set<Polygon> polygoneSet = HashSet<Polygon>();
 Set<Polygon> multipolygonSet = HashSet<Polygon>();
//List<LatLng> polygonPoints = [];

  //Fetch park data from MariaDB
  Future<void> fetchParksData() async {
    try {
      var mariaDB = MariaDB();
      parksData = await mariaDB.fetchParks();
      setState(() {
        //Create markers for each park
        for (var row in parksData!) {
          final marker = Marker(
            markerId: MarkerId(row['name']),
            position: LatLng(row['latitude'], row['longitude']),
            infoWindow: InfoWindow(
              title: row['name'],
            ),
          );
          markers.add(marker);
        }
      });
    } catch (error) {
      // Handle the error here
      print('Error: $error');
    }
  }


  Future<void> fetchPolygonPoints() async {
    var mariaDB = MariaDB();
    final polygonData = await mariaDB.fetchPolygons();
    polygonData.forEach((id, coordinates) {
      final polygonPoints = <LatLng>[];
      for (final coordinate in coordinates) {
        final latitude = coordinate['latitude'];
        final longitude = coordinate['longitude'];
        polygonPoints.add(LatLng(latitude, longitude));
      }
      final polygon = Polygon(
        polygonId: PolygonId(id.toString()),
        points: polygonPoints,
        fillColor: Colors.red,
        strokeColor: Colors.blue,
        strokeWidth: 4,
        geodesic: true,
      );
      polygoneSet.add(polygon);
    });
  }
  

    Future<void> fetchMultipolygonPoints() async {
    var mariaDB = MariaDB();
    final multiPolygonData = await mariaDB.fetchMultipolygons();
    multiPolygonData.forEach((id, coordinates) {
      final polygonPoints = <LatLng>[];
      for (final coordinate in coordinates) {
        final latitude = coordinate['latitude'];
        final longitude = coordinate['longitude'];
        polygonPoints.add(LatLng(latitude, longitude));
      }
      final polygon = Polygon(
        polygonId: PolygonId(id.toString()),
        points: polygonPoints,
        fillColor: Colors.red,
        strokeColor: Colors.blue,
        strokeWidth: 4,
        geodesic: true,
      );
      multipolygonSet.add(polygon);
    });
  }

  @override
  void initState() {
    super.initState();

    //Call fetchParksData() when our widget is created
    fetchParksData();
    fetchPolygonPoints();
    fetchMultipolygonPoints();
  }
/*
  // Function to add a polygon dynamically
  void addPolygon(String id, List<LatLng> points, Color fillColor, Color strokeColor, int strokeWidth) {
    final polygon = Polygon(
      polygonId: PolygonId(id),
      points: points,
      fillColor: fillColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      geodesic: true,
    );
    _polygoneSet.add(polygon);
  }

  // Function to remove a polygon dynamically
  void removePolygon(Polygon polygon) {
    _polygoneSet.remove(polygon);
  }
  */


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(59.29796402722902, 18.12241581476829),
          zoom: 15,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: showParks ? markers : <Marker>{},
        polygons: showPolygons ? multipolygonSet : <Polygon>{},
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  showParks = !showParks;
                });
              },
              tooltip: 'Toggle Parks',
              child: Icon(showParks ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  showPolygons = !showPolygons;
                });
              },
              tooltip: 'Toggle Polygons',
              child: Icon(showPolygons ? Icons.visibility : Icons.visibility_off),
            ),
          ),
        ],
      ),
    );
  }
}
