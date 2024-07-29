import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPage extends StatefulWidget {
  final String? workshopAddress; // Workshop address passed from previous screen
  const MapPage({Key? key, this.workshopAddress}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? currentLatLng;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  List<Marker> markers = [];
  List<LatLng> polylinePoints = [];

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
    // Check if workshopAddress is provided and trigger search if so
    if (widget.workshopAddress != null) {
      _searchController.text = widget.workshopAddress!;
      _searchLocation();
    }
  }

  Future<void> _setInitialLocation() async {
    Position position = await _determinePosition();
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
      markers.add(Marker(
        point: currentLatLng!,
        width: 80,
        height: 80,
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 40,
        ),
      ));
    });
    _mapController.move(currentLatLng!, 13.0);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text;
    final encodedQuery = Uri.encodeComponent(query); // Encode the search query
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result.isNotEmpty) {
        final coordinates = result[0];
        final searchedLatLng =
        LatLng(double.parse(coordinates['lat']), double.parse(coordinates['lon']));

        setState(() {
          markers.add(Marker(
            point: searchedLatLng,
            width: 80,
            height: 80,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ));
        });

        _mapController.move(searchedLatLng, 13.0);
        if (currentLatLng != null) {
          _getDirections(currentLatLng!, searchedLatLng);
        }
      }
    } else {
      // Handle HTTP error, e.g., show a snackbar or dialog
      print('Error fetching location data: ${response.statusCode}');
    }
  }

  Future<void> _getDirections(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry']['coordinates'];
      final coordinates = geometry.map<LatLng>((coord) {
        return LatLng(coord[1], coord[0]);
      }).toList();

      setState(() {
        polylinePoints = coordinates;
      });
    } else {
      // Handle HTTP error, e.g., show a snackbar or dialog
      print('Error fetching directions: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: const Text(
          'Map',
          style: TextStyle(
            fontFamily: 'Cinzel', // Antique themed font
            color: Color(0xFF3E2723),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications button pressed
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout button pressed
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                'User Name', // Replace with dynamic user name
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  color: Color(0xFF3E2723),
                ),
              ),
              accountEmail: Text(
                'user@example.com', // Replace with dynamic user email
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  color: Color(0xFF3E2723),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'U', // Replace with dynamic user initial
                  style: const TextStyle(
                    fontSize: 40.0,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFBFA58D), // Antique color
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: () {
                Navigator.pushNamed(context, '/homepage'); // Navigate to HomePage
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: () {
                Navigator.pushNamed(context, '/map'); // Navigate to MapPage
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('List of Workshops', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: () {
                Navigator.pushNamed(context, '/workshops'); // Navigate to WorkshopsPage
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Chat', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: () {
                Navigator.pushNamed(context, '/chatlist'); // Navigate to ChatListPage
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: () {
                // Handle logout
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Location',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {
                    _setInitialLocation();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentLatLng ?? const LatLng(51.5, -0.09),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: markers,
                ),
                if (polylinePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: polylinePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xFFBFA58D), // Antique color
      //   child: const Icon(Icons.zoom_out_map),
      //   onPressed: () {
      //     // Handle floating action button pressed
      //   },
      // ),
    );
  }
}
