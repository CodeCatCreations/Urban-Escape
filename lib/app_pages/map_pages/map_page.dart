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

  final greenIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  final blueIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  final magentaIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  late GoogleMapController mapController;
  bool showParks = false;


  final Set<Marker> parkMarkers = {};
  Set<Marker> savedMarkers = LocalUser.savedMarkers;

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

  @override
  void initState() {
    super.initState();

    LocalUser().loadData();
    savedMarkers = LocalUser.savedMarkers;
    //Call fetchParksData() when our widget is created
    fetchParksData();

    //fetchPolygonPoints();
  }

  void createSavedMarker(LatLng position) {
    setState(() {
      // Check if the marker with the given MarkerId already exists in savedMarkers
      if (savedMarkers.contains(Marker(markerId: MarkerId(position.toString())))) {
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
          return marker.copyWith(infoWindowParam: marker.infoWindow.copyWith(titleParam: newTitle), iconParam: blueIcon);
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
                  const ScreenCoordinate(x: 500, y: 500),
                );
                createSavedMarker(center);
              },

              child: const Icon(Icons.add),
            ),

          ),
      ]),
    );
  }
}
