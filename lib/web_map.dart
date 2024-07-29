import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'map_interface.dart';

class WebMap extends MapInterface {
  const WebMap({super.key});

  @override
  _WebMapState createState() => _WebMapState();
}

class _WebMapState extends MapInterfaceState {
  @override
  LatLng get initialPosition => LatLng(45.521563, -122.677433);

  @override
  void onMapCreated(controller) {
    // Add web-specific map creation logic here
  }

  @override
  Widget buildMap() {
    return Center(
      child: Text("Google Maps for Web is not implemented"),
    );
  }
}
