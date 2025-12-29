import 'package:flutter/material.dart';
import 'package:google_location/models/saves_polyline_model.dart';
import 'google_maps_scree.dart';
import '../models/custom_marker_model.dart';

class SavedPolylinesPage extends StatelessWidget {
  final List<SavedRouteModel> savedRoutes;
  final Function(CustomMarkerModel) onMarkerAdded;

  const SavedPolylinesPage({
    super.key,
    required this.savedRoutes,
    required this.onMarkerAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Polylines")),
      body: savedRoutes.isEmpty
          ? const Center(child: Text("No saved routes"))
          : ListView.builder(
              itemCount: savedRoutes.length,
              itemBuilder: (context, index) {
                final route = savedRoutes[index];

                return ListTile(
                  leading: const Icon(Icons.alt_route),
                  title: Text(route.name),
                  subtitle: Text(
                    "${route.start.Lat}, ${route.start.Lng} --> "
                    "${route.end.Lat}, ${route.end.Lng}",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GoogleMapsScreen(
                          markersForPolyline: [
                            route.start,
                            route.end,
                          ],
                          onMarkerAdded: onMarkerAdded,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
