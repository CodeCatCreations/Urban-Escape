import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_escape_application/database/maria_sql.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  late GoogleMapController mapController;
  //List<LatLng> polygonPoints = [];
  bool showParks = false;


  final Set<Marker> parkMarkers = {};
  final Set<Marker> savedMarkers = {};

  final List<LatLng> polygonPoints = [
    LatLng(59.31363187438705, 17.997699807602697),
    LatLng(59.313631872485, 17.997594455279266),
    LatLng(59.31364084844889, 17.997559337194904),
    LatLng(59.31364084811887, 17.997541778469696),
    LatLng(59.31364982440329, 17.997524219092018),
    LatLng(59.313658801020104, 17.997524218439533),
    LatLng(59.31365880135248, 17.997541777173986),
    LatLng(59.313667778952286, 17.997594452743375),
    LatLng(59.31366778207505, 17.997770040134203),
    LatLng(59.3136677904782, 17.99833191978511),
    LatLng(59.31365881495557, 17.99841971389707),
    LatLng(59.31365881516727, 17.998437272631538),
    LatLng(59.313649838338705, 17.998419714313542),
    LatLng(59.31364983812462, 17.998402155583705),
    LatLng(59.313640861291354, 17.9983845972796),
    LatLng(59.313640857506165, 17.998103657676218),
    LatLng(59.31364085455251, 17.997910511698933),
    LatLng(59.31363187438705, 17.997699807602697),
  ];
  

  List<Map<String, dynamic>>? parksData;

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
          parkMarkers.add(marker);
        }
      });
    } catch (error) {
      // Handle the error here
      print('Error: $error');
    }
  }
/*
    Future<void> fetchPolygonPoints() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/polygon.json');
      final json = jsonDecode(jsonString);
      //final coordinates = json['features'][0]['geometry']['coordinates'][0];
      final coordinatesList = json['features']
        .sublist(0, 10) // display only the first 10 polygons
        .map((feature) => feature['geometry']['coordinates'][0])
        .toList();

      // Convert the list of coordinates to LatLng objects
      polygonPoints = coordinates.map((coord) {
        return LatLng(coord[1], coord[0]);
      }).toList();
    } catch (error) {
      // Handle the error here
      print('Error: $error');
    }
  }
  */

  @override
  void initState() {
    super.initState();

    //Call fetchParksData() when our widget is created
    fetchParksData();
    //fetchPolygonPoints();
  }

  void createSavedMarker(LatLng position) {
    bool markerDragged = false;
    setState(() {
      savedMarkers.add(
        Marker(
          markerId: MarkerId('saved-${savedMarkers.length + 1}'),
          position: position,
          draggable: true, // Set draggable to true for initially created markers
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onDragEnd: (LatLng newPosition) {

            if (!markerDragged) {
              setState(() {
                markerDragged = true;
              });
            }

            // When a marker is dragged to a new position, update the marker's position in the set
            savedMarkers.removeWhere((marker) => marker.markerId == MarkerId('saved-${savedMarkers.length + 1}'));
            savedMarkers.add(
              Marker(
                markerId: MarkerId('saved-${savedMarkers.length + 1}'),
                position: newPosition,
                draggable: false, // Set draggable to false for dragged markers
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
              ),
            );

          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> allMarkers = {...parkMarkers, ...savedMarkers};

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(59.31363187438705, 17.997699807602697),
          zoom: 20,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: showParks ? allMarkers : savedMarkers,
        polygons: {
          Polygon(
            polygonId: const PolygonId('polygon'),
            points: polygonPoints,
            fillColor: Colors.blue.withOpacity(0.1),
            strokeColor: Colors.black,
            strokeWidth: 2,
          ),
        },
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  showParks = !showParks;
                });
              },
              child: Icon(showParks ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          Positioned(
            bottom: 85.0,
            left: 16.0,
            child: FloatingActionButton(
              onPressed: () async {
                // Get the center coordinates of the map view
                LatLng center = await mapController.getLatLng(
                  const ScreenCoordinate(x: 500, y: 500)
                );
                createSavedMarker(center);
              },

              child: const Icon(Icons.add),
            ),

          ),
        ],
      ),
    );
  }
}
