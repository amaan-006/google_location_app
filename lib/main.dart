import 'package:flutter/material.dart';
import 'package:google_location/customs/custom_button.dart';
import 'package:google_location/models/custom_marker_model.dart';
import 'package:google_location/models/saves_polyline_model.dart';
import 'package:google_location/screens/create_marker.dart';
import 'package:google_location/screens/google_maps_scree.dart';
import 'package:google_location/screens/saves_polylines.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<CustomMarkerModel> markerList = [];
  final List<CustomMarkerModel> selectedList = [];
  final List<SavedRouteModel> savedRoutes = [];

  void addMarker(CustomMarkerModel marker) {
    setState(() {
      markerList.add(marker);
    });
  }

  void onMarkerSelect(CustomMarkerModel marker, bool value) {
    setState(() {
      if (value) {
        if (selectedList.length == 2) {
          selectedList.first.selected = false;
          selectedList.removeAt(0);
        }
        marker.selected = true;
        selectedList.add(marker);
      } else {
        marker.selected = false;
        selectedList.remove(marker);
      }
    });
  }

  void openPolylineMap() {
    if (selectedList.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select exactly 2 locations")),
      );
      return;
    }
    // final routeMarkers = List<CustomMarkerModel>.from(selectedList);

    final start = selectedList[0];
    final end = selectedList[1];

    setState(() {
      savedRoutes.add(
        SavedRouteModel(
          start: start,
          end: end,
          name: "${start.name} - ${end.name}",
        ),
      );
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoogleMapsScreen(
          markersForPolyline: [start, end],
          onMarkerAdded: addMarker,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SavedPolylinesPage(
                          savedRoutes: savedRoutes,
                          onMarkerAdded: addMarker,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Polylines",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GoogleMapsScreen(
                          markersForPolyline: const [],
                          onMarkerAdded: addMarker,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Go To Map",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),

            const Text(
              "Marked list",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const Divider(),

            Expanded(
              child: markerList.isEmpty
                  ? const Center(child: Text("No marker added"))
                  : ListView.builder(
                      itemCount: markerList.length,
                      itemBuilder: (context, index) {
                        final m = markerList[index];
                        return ListTile(
                          leading: Checkbox(
                            value: m.selected,
                            onChanged: (val) => onMarkerSelect(m, val ?? false),
                          ),
                          title: Text(m.name),
                          subtitle: Text("Lat: ${m.Lat}, Lng: ${m.Lng}"),
                        );
                      },
                    ),
            ),

            CustomButton(title: "Create Polyline", onPressed: openPolylineMap),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(
            Icons.add_location_alt_outlined,
            color: Colors.amber,
          ),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateMarkerpage()),
            );

            if (result != null && result is CustomMarkerModel) {
              addMarker(result);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GoogleMapsScreen(
                    initialMarker: result,
                    markersForPolyline: const [],
                    onMarkerAdded: addMarker,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
