import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  LocationData? currentLocation;
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  final String orsApiKey =
      '5b3ce3597851110001cf62485cdc29e0f1b74e4f8aa25989caba046a';

  final LatLng bengkalisCoordinates = LatLng(1.4823499, 102.11306);
  double _zoomLevel = 15.0;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _setInitialLocation();
    _fetchMarkers();
  }

  void _initializeMap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(bengkalisCoordinates, _zoomLevel);
    });
  }

  void _setInitialLocation() {
    setState(() {
      currentLocation = LocationData.fromMap({
        'latitude': bengkalisCoordinates.latitude,
        'longitude': bengkalisCoordinates.longitude,
      });
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: bengkalisCoordinates,
          child: const Icon(Icons.person,
              color: Colors.blue,
              size: 40.0),  
        ),
      );
    });
  }

  Future<void> _fetchMarkers() async {
    try {
      final response = await http.get(
          Uri.parse('http://10.11.8.25/hotel_bengkalis/api/input_lokasi.php'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          markers.addAll(data.map<Marker>((hotel) {
            double latitude = hotel['latitude'] != null
                ? double.parse(hotel['latitude'])
                : 0.0;
            double longitude = hotel['longitude'] != null
                ? double.parse(hotel['longitude'])
                : 0.0;

            Color markerColor =
                hotel['kategori'] == 'Hotel' ? Colors.blue : Colors.green;

            return Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(latitude, longitude),
              child: GestureDetector(
                onTap: () => _showMarkerInfo(
                  LatLng(latitude, longitude),
                  hotel['name'] ?? 'No Name',
                  hotel['description'] ?? 'No Description',
                  hotel['kategori'] ?? 'No Category',
                ),
                child: Icon(Icons.location_on, color: markerColor, size: 40.0),
              ),
            );
          }).toList());
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load markers');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to load markers');
    }
  }

  void _showMarkerInfo(
      LatLng point, String title, String description, String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '$category: $title',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(description),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tutup',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(
                'Lihat Rute',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showTransportOptions(point);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTransportOptions(LatLng destination) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Pilih Mode Transportasi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTransportOption(
                icon: Icons.directions_walk,
                title: 'Jalan Kaki',
                onTap: () {
                  _runAStarAlgorithm(destination, 'foot-walking');
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 10),
              _buildTransportOption(
                icon: Icons.motorcycle,
                title: 'Sepeda Motor',
                onTap: () {
                  _runAStarAlgorithm(destination, 'cycling-regular');
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 10),
              _buildTransportOption(
                icon: Icons.directions_car,
                title: 'Mobil',
                onTap: () {
                  _runAStarAlgorithm(destination, 'driving-car');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransportOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            SizedBox(width: 16),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Future<void> _runAStarAlgorithm(
      LatLng destination, String transportMode) async {
    if (currentLocation == null) return;

    await _getRoute(destination, transportMode);
  }

  Future<void> _getRoute(LatLng destination, String transportMode) async {
    if (currentLocation == null) return;

    final start =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    final response = await http.get(
      Uri.parse(
        'https://api.openrouteservice.org/v2/directions/$transportMode?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords =
          data['features'][0]['geometry']['coordinates'];
      final double distance =
          data['features'][0]['properties']['segments'][0]['distance'];
      final double duration =
          data['features'][0]['properties']['segments'][0]['duration'];

      setState(() {
        routePoints =
            coords.map((coord) => LatLng(coord[1], coord[0])).toList();
        mapController.move(destination, _zoomLevel);
      });

      _showRouteInfo(distance, duration);
    } else {
      print('Gagal mengambil rute');
    }
  }

  void _showRouteInfo(double distance, double duration) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Informasi Rute',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRouteInfoRow(
                icon: Icons.straighten,
                title: 'Jarak',
                value: '${(distance / 1000).toStringAsFixed(2)} km',
              ),
              SizedBox(height: 8),
              _buildRouteInfoRow(
                icon: Icons.timer,
                title: 'Estimasi Waktu',
                value: '${(duration / 60).toStringAsFixed(0)} menit',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tutup',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRouteInfoRow(
      {required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        SizedBox(width: 8),
        Text(
          '$title: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Hotel & Wisma..'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(currentLocation?.latitude ?? 1.4823499,
                    currentLocation?.longitude ?? 102.11306),
                initialZoom: _zoomLevel,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                MarkerLayer(
                  markers: markers,
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Slider(
            value: _zoomLevel,
            min: 1.0,
            max: 20.0,
            divisions: 19,
            label: _zoomLevel.toStringAsFixed(1),
            onChanged: (double value) {
              setState(() {
                _zoomLevel = value;
                mapController.move(
                    LatLng(currentLocation?.latitude ?? 1.4823499,
                        currentLocation?.longitude ?? 102.11306),
                    _zoomLevel);
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                routePoints.clear(); // Menghapus rute dari peta
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
