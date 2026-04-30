import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'search_screen.dart';
import 'map_screen.dart';
import 'building_screen.dart';
import 'favourite_screen.dart';
import 'qr_scanner_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  final Color navBarColor = const Color(0xFF1B5E20);
  final Color buttonColor = const Color(0xFF006940);

  String getUserName(String email) {
    return email.split('@')[0];
  }

  @override
  Widget build(BuildContext context) {

    String email = user?.email ?? "";
    String name = getUserName(email);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: Column(
        children: [

          //HEADER 
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: BoxDecoration(
              color: navBarColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [

                const Spacer(),

                const Text(
                  "Classroom Finder",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.person, color: Colors.white),
                ),

                const SizedBox(width: 15),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //GREETING
                  Text(
                    "Hey $name 👋",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // GRID
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.4,
                    children: [

                      _menuCard("Find Classroom", Icons.search, () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SearchScreen()));
                      }),

                      _menuCard("Open Map", Icons.location_on, () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => MapScreen(data: {})));
                      }),

                      _menuCard("Buildings", Icons.business, () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const BuildingScreen()));
                      }),

                      _menuCard("Scan QR", Icons.qr_code_scanner, () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const QRScannerScreen()));
                      }),
                    ],
                  ),

                  const SizedBox(height: 25),

                  //AVAILABLE ROOMS
                  const Text(
                    "Available Rooms",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("classrooms")
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var docs = snapshot.data!.docs;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: docs.map((doc) {

                            var data = doc.data();
                            String room = data["room"] ?? "Unknown";

                            return Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.meeting_room),
                                  title: Text(room),
                                ),
                                const Divider(),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // NAV BAR
      bottomNavigationBar: Container(
        height: 80,
        color: navBarColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.search, "Search", 1),
            _navItem(Icons.map, "Map", 2),
            _navItem(Icons.business, "Buildings", 3),
            _navItem(Icons.favorite, "Favorites", 4),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {

        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const SearchScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => MapScreen(data: {})));
        } else if (index == 3) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const BuildingScreen()));
        } else if (index == 4) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const FavouriteScreen()));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}