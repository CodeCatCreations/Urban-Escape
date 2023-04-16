import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_escape_application/maria_sql_actions/maria_sql.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};

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
        markers.add(marker);
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

    //Call fetchParksData() when our widget is created
    fetchParksData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(59.3293, 18.0686),
          zoom: 12,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: markers,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}