import 'package:flutter/material.dart';
import 'package:google_location/models/custom_marker_model.dart';



class MarkerListScreen extends StatelessWidget {
  final List<CustomMarkerModel> markers;

  const MarkerListScreen({super.key, required this.markers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location Marked List")),
      body: ListView.builder(
        itemCount: markers.length,
        itemBuilder: (_, index) {
          final marker = markers[index];
          return ListTile(
            leading: Icon(Icons.location_city),
            title: Text("Lat:${marker.Lat}"),
            subtitle: Text("Long:${marker.Lng}"),
          );
        },
      ),
    );
  }
}
