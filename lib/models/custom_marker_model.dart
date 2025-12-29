class CustomMarkerModel {
  final double Lat;
  final double Lng;
  final String name;
  final String description;
  bool selected;

  CustomMarkerModel({
    required this.Lat,
    required this.Lng,
    required this.name,
    required this.description,
    this.selected = false,
  });
}
