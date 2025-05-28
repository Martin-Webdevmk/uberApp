import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final mapCenter = LatLng(41.7961, 20.9039); // Gostivar, Macedonia

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap Example'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: mapCenter,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.martinaleksoski.usersapp',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: mapCenter,
                width: 80,
                height: 80,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
