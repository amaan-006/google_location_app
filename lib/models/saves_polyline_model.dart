import 'package:google_location/models/custom_marker_model.dart';

class SavedRouteModel {
  final CustomMarkerModel start;
  final CustomMarkerModel end;
  final String name;

  SavedRouteModel({
    required this.start,
    required this.end,
    required this.name,
  });
}