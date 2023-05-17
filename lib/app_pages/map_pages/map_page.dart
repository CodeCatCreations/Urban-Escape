import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_escape_application/app_pages/progress_page/daily_banner_page.dart';
import 'package:urban_escape_application/database/maria_sql.dart';
import 'package:urban_escape_application/database//local_user.dart';
import 'package:geolocator/geolocator.dart';

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
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(59.3293, 18.0686),
    zoom: 12,
  );
  Set<Marker> markers = {};
  bool showParks = false;
  bool showHighNoisePollutionPolygons = false;
  bool showLowPollutionPolygons = false;
  bool showEcoSignificantAreasPolygons = false;
  bool showFilters = false;
  bool addMarkerPressed = false;

  final Set<Marker> parkMarkers = {};
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
        fillColor: Colors.red.shade700,
        strokeColor: Colors.red.shade400,
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
        strokeColor: Colors.green.shade500,
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
    fetchParksData();
    fetchEcoSignificantAreasPolygons();
    fetchHighNoisePollutionPolygonPoints();
  }

  void createSavedMarker(LatLng position) {
    setState(() {
      // Check if the marker with the given MarkerId already exists in savedMarkers
      if (LocalUser.savedMarkers
          .contains(Marker(markerId: MarkerId(position.toString())))) {
        return;
      }

      LocalUser.savedMarkers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          draggable: true,
          icon: magentaIcon,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              Marker oldMarker = LocalUser.savedMarkers.firstWhere(
                  (marker) => marker.markerId.value == position.toString());
              Marker newMarker = Marker(
                  markerId: MarkerId(newPosition.toString()),
                  position: newPosition,
                  draggable: false,
                  icon: blueIcon,
                  infoWindow: createInfoWindow(newPosition, context));

              LocalUser.savedMarkers.remove(oldMarker);
              LocalUser.savedMarkers.add(newMarker);

              addMarkerPressed = false;
              setState(() {});
              LocalUser().saveData();
            });
          },
        ),
      );
    });
  }

  void changeMarkerTitle(LatLng position, String newTitle) {
    // Refresh the map to show the new marker color
    LocalUser.savedMarkers = LocalUser.savedMarkers.map((marker) {
      if (marker.markerId.value == position.toString()) {
        return marker.copyWith(
          draggableParam: false,
          iconParam: blueIcon,
          infoWindowParam: marker.infoWindow.copyWith(titleParam: newTitle),
        );
      }
      return marker;
    }).toSet(); // Convert back to a Set

    setState(() {});
    LocalUser().saveData();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied");
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> allMarkers = {...parkMarkers, ...LocalUser.savedMarkers};

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(59.3293, 18.0686),
          zoom: 12,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: showParks ? allMarkers : LocalUser.savedMarkers,
        polygons: {
          if (showHighNoisePollutionPolygons) ...highNoisePollutionPolygonSet,
          if (showLowPollutionPolygons) ...lowNoisePollutionPolygonSet,
          if (showEcoSignificantAreasPolygons) ...ecoSignificantAreasPolygonSet,
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 15,
            right: 65,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white70,
              ),
              child: IconButton(
                onPressed: () async {
                  Position position = await _determinePosition();
                  mapController.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target:
                              LatLng(position.latitude, position.longitude), zoom: 15)));
                  markers.add(Marker(markerId: const MarkerId("currentLocation"), position: LatLng(position.latitude, position.longitude)));
                  setState(() {});
                },
                icon: Image.asset(
                  'assets/icons/gps.png',
                  width: 60,
                  height: 60,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 100.0,
            child: ElevatedButton(
              onPressed: () async {},
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
                elevation: MaterialStateProperty.all<double>(0),
              ),
              child: addMarkerPressed
                  ? ElevatedButton(
                      onPressed: null,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            return Colors.orange;
                          },
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8.0),
                        child: const Text(
                          'Drag the marker',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        addMarkerPressed = true;
                        // Get the center coordinates of the map view
                        LatLng center = await mapController.getLatLng(
                          const ScreenCoordinate(x: 500, y: 500),
                        );
                        createSavedMarker(center);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            return Colors.blue;
                          },
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8.0),
                        child: const Text(
                          'Create Marker',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 25.0,
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
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.only(left: 8),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return showParks
                              ? Colors.grey
                              : Colors.green.shade500;
                        },
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(showParks ? 'Hide Parks' : 'Show Parks'),
                        const SizedBox(),
                        IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () {
                            ProgressBannerBar.show(context,
                                'Shows Parks Registered In Stockholm Municipality');
                          },
                        ),
                      ],
                    ),
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
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return showHighNoisePollutionPolygons
                              ? Colors.grey
                              : Colors.green.shade500;
                        },
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(showHighNoisePollutionPolygons
                            ? 'Hide High Noise Pollution'
                            : 'Show High Noise Pollution'),
                        const SizedBox(width: 5),
                        IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () {
                            ProgressBannerBar.show(context,
                                'This Filter Displays Noise Pollution over 70 decibels');
                          },
                        ),
                      ],
                    ),
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
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 8),
                        ),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey;
                            }
                            return showEcoSignificantAreasPolygons
                                ? Colors.grey
                                : Colors.green.shade500;
                          },
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(showEcoSignificantAreasPolygons
                              ? 'Hide Eco Significant Areas'
                              : 'Show Eco Significant Areas'),
                          const SizedBox(width: 5),
                          IconButton(
                            icon: const Icon(Icons.info),
                            onPressed: () {
                              ProgressBannerBar.show(context,
                                  'This Filter Displays Nature Conservation Areas');
                            },
                          ),
                        ],
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  InfoWindow createInfoWindow(LatLng newPosition, BuildContext context) {
    return InfoWindow(
      title: newPosition.toString(), // Set the new title for the marker
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
                  child: const Text("Remove"),
                  onPressed: () {
                    LocalUser.savedMarkers.removeWhere((marker) =>
                        marker.markerId.value == newPosition.toString());
                    setState(() {});
                    LocalUser().saveData();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Save"),
                  onPressed: () {
                    changeMarkerTitle(newPosition, newTitle);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
