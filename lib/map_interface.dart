import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

abstract class MapInterface extends StatefulWidget {
  const MapInterface({super.key});
}

abstract class MapInterfaceState extends State<MapInterface> {
  void onMapCreated(dynamic controller);
  Widget buildMap();
  LatLng get initialPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: buildMap(),
    );
  }
}
