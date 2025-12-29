import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/custom_marker_model.dart';

class GoogleMapsScreen extends StatefulWidget {
  final List<CustomMarkerModel> markersForPolyline;
  final Function(CustomMarkerModel) onMarkerAdded;
  final CustomMarkerModel? initialMarker;

  const GoogleMapsScreen({
    super.key,
    required this.markersForPolyline,
    required this.onMarkerAdded,
    this.initialMarker,
  });

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  GoogleMapController? _controller;

  LatLng? _currentLatLng;

  static const String _webApiKey = "AIzaSyD6Nb4DBrQ1FywomyMTGnNMKUm4G6Fxm_A";

  @override
  void initState() {
    super.initState();
    _initLocation();
    _addSelectedMarkers();
    _addInitialMarker();
  }

  Future<String> _getPlaceName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) return "Unknown Location";

      final place = placemarks.first;
      final nameParts = [
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
      ].where((e) => e != null && e.isNotEmpty).toList();

      return nameParts.take(2).join(", ");
    } catch (e) {
      return "unknown location";
    }
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentLatLng = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("me"),
          position: _currentLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: "My Location"),
        ),
      );
    });

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng!, 15));
  }

  void _addInitialMarker() {
    print("Marker Added");
    if (widget.initialMarker == null) return;
    final m = widget.initialMarker!;
    setState(() {
      print("Marker Added");
      _markers.add(
        Marker(
          markerId: MarkerId("initial_${m.Lat}_${m.Lng}"),
          position: LatLng(m.Lat, m.Lng),
          infoWindow: InfoWindow(title: m.name),
        ),
      );
    });
  }

  void _addSelectedMarkers() {
    for (final m in widget.markersForPolyline) {
      _markers.add(
        Marker(
          markerId: MarkerId("${m.Lat}-${m.Lng}"),
          position: LatLng(m.Lat, m.Lng),
          infoWindow: InfoWindow(title: m.name),
        ),
      );
    }
  }

  void _onMapTap(LatLng pos) async {
  final placeName = await _getPlaceName(
    pos.latitude,
    pos.longitude,
  );

  final marker = CustomMarkerModel(
    Lat: pos.latitude,
    Lng: pos.longitude,
    name: placeName, 
    description: "Added from map",
  );

  setState(() {
    _markers.add(
      Marker(
        markerId: MarkerId(pos.toString()),
        position: pos,
        infoWindow: InfoWindow(title: placeName),
      ),
    );
  });

  widget.onMarkerAdded(marker);
}


  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  Future<void> _drawRoute(
    CustomMarkerModel start,
    CustomMarkerModel end,
  ) async {
    debugPrint(
      "Route from ${start.Lat},${start.Lng} "
      "to end ${end.Lat} , ${end.Lng}",
    );

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json"
      "?origin=${start.Lat},${start.Lng}"
      "&destination=${end.Lat},${end.Lng}"
      "&mode=driving"
      "&key=$_webApiKey",
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data['status'] != "OK" ||
        data['routes'] == null ||
        data['routes'].isEmpty) {
      debugPrint("Route error :${data['status']}");
      debugPrint("Full response : ${res.body}");
      return;
    }
    final encoded = data['routes'][0]['overview_polyline']['points'];
    final points = _decodePolyline(encoded);

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 6,
          points: points,
        ),
      );
    });

    _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(_bounds(points), 60),
    );
  }

  LatLngBounds _bounds(List<LatLng> list) {
    double minLat = list.first.latitude;
    double maxLat = list.first.latitude;
    double minLng = list.first.longitude;
    double maxLng = list.first.longitude;

    for (final p in list) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Maps")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(28.6139, 77.2090),
          zoom: 12,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onTap: _onMapTap,
        onMapCreated: (controller) {
          _controller = controller;

          if (widget.markersForPolyline.isNotEmpty) {
            final first = widget.markersForPolyline.first;
            _controller!.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(first.Lat, first.Lng), 14),
            );
          }

          if (widget.markersForPolyline.length == 2) {
            _drawRoute(
              widget.markersForPolyline[0],
              widget.markersForPolyline[1],
            );
          }
        },
      ),
    );
  }
}
