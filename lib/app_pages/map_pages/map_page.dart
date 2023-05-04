import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_escape_application/database/maria_sql.dart';
import 'package:urban_escape_application/database//local_user.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final greenIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  final blueIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  final magentaIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  late GoogleMapController mapController;
  bool showParks = false;
  bool showHighNoisePollutionPolygons = false;
  bool showLowPollutionPolygons = false;
  bool showEcoSignificantAreasPolygons = false;
  bool showFilters = false;
  bool addMarkerPressed = false;

  final Set<Marker> parkMarkers = {};
  Set<Marker> savedMarkers = LocalUser.savedMarkers;
  Set<Polygon> highNoisePollutionPolygonSet = HashSet<Polygon>();
  Set<Polygon> lowNoisePollutionPolygonSet = HashSet<Polygon>();
  Set<Polygon> ecoSignificantAreasPolygonSet = HashSet<Polygon>();
  Set<Polygon> biotopePolygonSet = HashSet<Polygon>();
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
            icon: greenIcon,
            infoWindow: InfoWindow(
              title: row['name'],
            ),
          );
          parkMarkers.add(marker);
        }
      });
    } catch (error) {
      // Handle the error here
    }
  }

  Future<void> fetchLowNoisePollutionPolygonPoints() async {
    var mariaDB = MariaDB();
    final polygonData = await mariaDB.fetchLowNoisePollutionPolygons();
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
      lowNoisePollutionPolygonSet.add(polygon);
    });
  }

  Future<void> fetchHighNoisePollutionPolygonPoints() async {
    var mariaDB = MariaDB();
    final polygonData = await mariaDB.fetchHighNoisePollutionPolygons();
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
      highNoisePollutionPolygonSet.add(polygon);
    });
  }

  Future<void> fetchEcoSignificantAreasPolygons() async {
    var mariaDB = MariaDB();
    final multiPolygonData = await mariaDB.fetchEcoSignificantAreasPolygons();
    multiPolygonData.forEach((id, coordinates) {
      final ecoSignificantAreasPolygonPoints = <LatLng>[];
      for (final coordinate in coordinates) {
        final latitude = coordinate['latitude'];
        final longitude = coordinate['longitude'];
        ecoSignificantAreasPolygonPoints.add(LatLng(latitude, longitude));
      }
      final polygon = Polygon(
        polygonId: PolygonId(id.toString()),
        points: ecoSignificantAreasPolygonPoints,
        fillColor: Colors.transparent,
        strokeColor: Colors.blue,
        strokeWidth: 4,
        geodesic: true,
      );
      ecoSignificantAreasPolygonSet.add(polygon);
    });
  }

  @override
  void initState() {
    super.initState();

    LocalUser().loadData();
    savedMarkers = LocalUser.savedMarkers;
    //Call fetchParksData() when our widget is created
    fetchParksData();
    fetchEcoSignificantAreasPolygons();
    fetchLowNoisePollutionPolygonPoints();
    fetchHighNoisePollutionPolygonPoints();
  }

  void createSavedMarker(LatLng position) {
    setState(() {
      // Check if the marker with the given MarkerId already exists in savedMarkers
      if (savedMarkers
          .contains(Marker(markerId: MarkerId(position.toString())))) {
        return;
      }

      savedMarkers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          draggable: true,
          icon: magentaIcon,
          onDragEnd: (LatLng newPosition) {
            setState(() {



              savedMarkers = savedMarkers.map((marker) {
                if (marker.markerId.value == position.toString()) {
                  // Create a new marker with a new markerId and all the other parameters
                  Marker newMarker = Marker(
                    markerId: MarkerId(newPosition.toString()),
                    position: newPosition,
                    draggable: false,
                    icon: blueIcon,
                    infoWindow: marker.infoWindow,
                  );
                  return newMarker;
                }
                return marker;
              }).toSet();




              addMarkerPressed = false;
              LocalUser().saveData();
              setState(() {});
            });



          },
          infoWindow: InfoWindow(
            title: position.toString(), // Set the new title for the marker
            onTap: () {
              // Show a dialog to allow the user to change the marker title
              showDialog(
                context: context,
                builder: (context) {
                  String newTitle = "";
                  return AlertDialog(
                    title: const Text("Change Marker Title"),
                    content: TextField(
                      onChanged: (value) {
                        newTitle = value;
                      },
                      decoration: const InputDecoration(
                        hintText: "Enter new title",
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("Save"),
                        onPressed: () {
                          changeMarkerTitle(position, newTitle);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );
    });
  }

  void changeMarkerTitle(LatLng position, String newTitle) {
    // Refresh the map to show the new marker color
    setState(() {
      savedMarkers = savedMarkers.map((marker) {
        if (marker.markerId.value == position.toString()) {
          return marker.copyWith(
            positionParam: position,
            draggableParam: false,
            iconParam: blueIcon,
            infoWindowParam: marker.infoWindow.copyWith(titleParam: newTitle),
          );
        }
        return marker;
      }).toSet(); // Convert back to a Set
      addMarkerPressed = false;
      LocalUser().saveData();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> allMarkers = {...parkMarkers, ...savedMarkers};

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(59.3293, 18.0686),
          zoom: 12,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: showParks ? allMarkers : savedMarkers,
        polygons: {
          if (showHighNoisePollutionPolygons) ...highNoisePollutionPolygonSet,
          if (showLowPollutionPolygons) ...lowNoisePollutionPolygonSet,
          if (showEcoSignificantAreasPolygons) ...ecoSignificantAreasPolygonSet,
        },
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            left: 85.0,
            child: ElevatedButton(
              onPressed: () async {},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                elevation: MaterialStateProperty.all<double>(0),

              ),

              child: addMarkerPressed ?

              ElevatedButton(
              onPressed: null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    return Colors.orange;
                  },
                ),
              ),
              child: Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: const Text(
                  'Drag the marker',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ) : ElevatedButton(
                onPressed: () async {
                  addMarkerPressed = true;
                  // Get the center coordinates of the map view
                  LatLng center = await mapController.getLatLng(
                    const ScreenCoordinate(x: 500, y: 500),
                  );
                  createSavedMarker(center);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return Colors.blue;
                    },
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  child: const Text(
                    'Create marker',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),




          Positioned(
            bottom: 16.0,
            left: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  showFilters = !showFilters;
                });
              },
              backgroundColor: Colors.black54,
              child: const Icon(Icons.filter_list, color: Colors.white),
            ),
          ),
          if (showFilters)
            Positioned(
              bottom: 100.0,
              left: 20.0,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showParks = !showParks;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return showParks ? Colors.grey : Colors.green;
                        },
                      ),
                    ),
                    child: Text(showParks ? 'Hide Parks' : 'Show Parks'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showHighNoisePollutionPolygons =
                            !showHighNoisePollutionPolygons;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return showHighNoisePollutionPolygons ? Colors.grey : Colors.black54;
                        },
                      ),
                    ),
                    child: Text(showHighNoisePollutionPolygons
                        ? 'Hide High Noise Pollution'
                        : 'Show High Noise Pollution'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showEcoSignificantAreasPolygons =
                            !showEcoSignificantAreasPolygons;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return showEcoSignificantAreasPolygons ? Colors.blue : Colors.lightBlueAccent;
                        },
                      ),
                    ),
                    child: Text(showEcoSignificantAreasPolygons
                        ? 'Hide Eco Significant Areas'
                        : 'Show Eco Significant Areas'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

}
