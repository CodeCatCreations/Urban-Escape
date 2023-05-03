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
  bool showPolygons = false;
  bool showFilters = false;

  final Set<Marker> parkMarkers = {};
  Set<Marker> savedMarkers = LocalUser.savedMarkers;
  Set<Polygon> highNoisePollutionPolygonSet = HashSet<Polygon>();
  Set<Polygon> lowNoisePollutionPolygonSet = HashSet<Polygon>();
  Set<Polygon> esboPolygonSet = HashSet<Polygon>();
  Set<Polygon> biotoppolygonsSet= HashSet<Polygon>();
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
      print('Error: $error');
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


      Future<void> fetchEsbopolygons() async {
    var mariaDB = MariaDB();
    final multiPolygonData = await mariaDB.fetchEsboPolygons();
    multiPolygonData.forEach((id, coordinates) {
      final esboPolygonPoints = <LatLng>[];
      for (final coordinate in coordinates) {
        final latitude = coordinate['latitude'];
        final longitude = coordinate['longitude'];
        esboPolygonPoints.add(LatLng(latitude, longitude));
      }
      final polygon = Polygon(
        polygonId: PolygonId(id.toString()),
        points: esboPolygonPoints,
        fillColor: Colors.transparent,
        strokeColor: Colors.blue,
        strokeWidth: 4,
        geodesic: true,
      );
      esboPolygonSet.add(polygon);
    });
  }

  Future<void> fetchBiotopPolygons() async {
    var mariaDB = MariaDB();
    final multiPolygonData = await mariaDB.fetchBiotopPolygons();
    multiPolygonData.forEach((id, coordinates) {
      final biotopPolygonPoints = <LatLng>[];
      for (final coordinate in coordinates) {
        final latitude = coordinate['latitude'];
        final longitude = coordinate['longitude'];
        biotopPolygonPoints.add(LatLng(latitude, longitude));
      }
      final polygon = Polygon(
        polygonId: PolygonId(id.toString()),
        points: biotopPolygonPoints,
        fillColor: Colors.transparent,
        strokeColor: Colors.orange,
        strokeWidth: 4,
        geodesic: true,
      );
      biotoppolygonsSet.add(polygon);
    });
  }

  @override
  void initState() {
    super.initState();

    LocalUser().loadData();
    savedMarkers = LocalUser.savedMarkers;
    //Call fetchParksData() when our widget is created
    fetchParksData();
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
                  return marker.copyWith(
                    positionParam: newPosition,
                    draggableParam: false,
                    iconParam: blueIcon,
                  );
                }
                return marker;
              }).toSet(); // Convert back to a Set
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
              infoWindowParam: marker.infoWindow.copyWith(titleParam: newTitle),
              iconParam: blueIcon);
        }
        return marker;
      }).toSet(); // Convert back to a Set
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
        polygons: showPolygons ? highNoisePollutionPolygonSet : <Polygon>{},
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            left: 85.0,
            child: FloatingActionButton(
              onPressed: () async {
                // Get the center coordinates of the map view
                LatLng center = await mapController.getLatLng(
                  const ScreenCoordinate(x: 500, y: 500),
                );
                createSavedMarker(center);
              },
              child: const Icon(Icons.add),
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
              child: const Icon(Icons.filter_list, color: Colors.white), // set the background color
            ),
          ),
          if (showFilters)
            Positioned(
              bottom: 100.0,
              left: 20.0,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        showParks = !showParks;
                      });
                    },
                    child: Icon(showParks ? Icons.visibility : Icons.visibility_off),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        showPolygons = !showPolygons;
                      });
                    },
                    tooltip: 'Toggle Polygons',
                    child: Icon(showPolygons ? Icons.visibility : Icons.visibility_off),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


/*
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
        polygons: showPolygons ? highNoisePollutionPolygonSet : <Polygon> {},
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
            backgroundColor: Colors.black54,
            child: const Icon(Icons.filter_list, color: Colors.white), // set the background color
          ),
          if (showFilters)
            Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      showParks = !showParks;
                    });
                  },
                  child: Icon(showParks ? Icons.visibility : Icons.visibility_off),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      showPolygons = !showPolygons;
                    });
                  },
                  tooltip: 'Toggle Polygons',
                  child: Icon(showPolygons ? Icons.visibility : Icons.visibility_off),
                ),
              ],
            ),
        ],
      ),
    );
  }

   */



  /*
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
        polygons: showPolygons ? highNoisePollutionPolygonSet : <Polygon> {},
      ),

      floatingActionButton: Stack(children: [
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
                const ScreenCoordinate(x: 500, y: 500),
              );
              createSavedMarker(center);
            },
            child: const Icon(Icons.add),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 80,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  showPolygons = !showPolygons;
                });
              },
              tooltip: 'Toggle Polygons',
              child: Icon(showPolygons ? Icons.visibility : Icons.visibility_off),
            ),
          )
      ]),
    );
  }

   */
}
