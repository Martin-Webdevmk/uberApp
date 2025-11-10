import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MapController _mapController;
  LatLng? _currentLatLng;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();

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

    await getUserInfoAndCheckBlockStatus();

  }


  getUserInfoAndCheckBlockStatus() async {
    // 🔹 Step 1: Create a reference to the user’s data in Firebase Realtime Database
    DatabaseReference usersRef = FirebaseDatabase.instance.ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    // 🔹 Step 2: Read data once (not listening continuously)
    await usersRef.once().then((snap)
    {
      //  CASE 1: If user data exists in the database
      // Extract the snapshot data as a Map for easier access
      if(snap.snapshot.value != null)
          {
        // CASE 1A: If user is not blocked
        if ((snap.snapshot.value as Map)["blockedStatus"] == "no")
        {
          // Save user name globally so you can use it anywhere (like Drawer)
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
          });
        }

        // ❌ CASE 1B: If user is blocked
        else //If user is blocked
            {
          FirebaseAuth.instance.signOut(); // Force logout

          Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));

          cMethods.displaySnackBar("you are blocked.Contact admin: info@webdevmk.com ", context);
        }
      }


      else //if user not found in database;
          {
        FirebaseAuth.instance.signOut(); // Force logout
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      }

    });

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

              const Divider(
                height: 1,
                color: Colors.white,
                thickness: 1,
              ),

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
                              color: Colors.white38,
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
