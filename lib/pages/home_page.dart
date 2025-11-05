import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:users_app/global/global_var.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MapController _mapController;
  LatLng? _currentLatLng;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    // Request permissions
    var status = await Permission.location.request();
    if (!status.isGranted) return;

    // Get position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    // Move map to user location
    _mapController.move(_currentLatLng!, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      appBar: AppBar(title: const Text('User Location Map')),
      drawer: Container(
        width: 255,
        color: Colors.black87,
        child: Drawer(

          backgroundColor: Colors.white10,
          child: ListView(
            children: [
               //header
              Container(
                color: Colors.black,
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 60,
                      ),
                      const SizedBox( width: 16,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Text(
                            "Profile",
                            style: const TextStyle(
                              color: Colors.white10,
                            ),
                          ),

                        ],
                      ),

                    ],
                  ),
                )
              ),

              const Divider(
                height: 1,
                color: Colors.white,
                thickness: 1,
              ),

              const SizedBox( height: 10,),

              //body
              ListTile(
                leading: IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.info, color: Colors.grey,),
                ),
                title: const Text("About", style: TextStyle(color: Colors.grey),),
              ),

              ListTile(
                leading: IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.logout, color: Colors.grey,),
                ),
                title: const Text("Logout", style: TextStyle(color: Colors.grey),),
              ),


            ],
          ),
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(41.7961, 20.9039), // Fallback to Gostivar
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.martinaleksoski.usersapp',
          ),
          if (_currentLatLng != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLatLng!,
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_pin_circle,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

          //Drawer Button
          Positioned(
            top: 42,
            left: 19,
            child: GestureDetector(
              onTap: ()
              {
                  sKey.currentState!.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const
                  [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 20,
                      child: Icon(
                        Icons.menu,
                        color: Colors.black87,
                      ),
                    )
              ),
            ),
          )

        ],
      ),
    );
  }
}
