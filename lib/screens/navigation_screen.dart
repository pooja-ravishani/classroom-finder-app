import 'package:flutter/material.dart';
import 'live_navigation_screen.dart';


import 'home_screen.dart';
import 'search_screen.dart';
import 'map_screen.dart';
import 'building_screen.dart';
import 'favourite_screen.dart';

class NavigationScreen extends StatefulWidget {
  final String roomName;
  final List path;

  const NavigationScreen({
    super.key,
    required this.roomName,
    required this.path,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  int _selectedIndex = 2; // default highlight

  // SAFE PATH
  List<Map<String, dynamic>> get safePath {
    try {
      return widget.path
          .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // DISTANCE
  int getTotalDistance() {
    int total = 0;

    for (var step in safePath) {
      final val = int.tryParse(
        (step['distance'] ?? "")
            .toString()
            .replaceAll(RegExp(r'[^0-9]'), ''),
      ) ?? 0;

      total += val;
    }

    return total;
  }

  // ETA
  String getETA() {
    final meters = getTotalDistance();
    if (meters == 0) return "1 min";
    return "${(meters / 70).ceil()} min";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: Column(
        children: [

          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            color: const Color(0xFF1B5E20),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    "Navigation",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // FIXED BACK BUTTON
                Positioned(
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // FIX
                    },
                  ),
                ),
              ],
            ),
          ),

          // IMAGE
          SizedBox(
            height: 230,
            width: double.infinity,
            child: Image.asset(
              'assets/entrance.png',
              fit: BoxFit.cover,
            ),
          ),

          // INFO CARD
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFF1B5E20), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Start", style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 5),
                  const Text("Entrance",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 15),

                  const Text("Destination", style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(widget.roomName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 15),

                  Text(
                    "ETA: ${getETA()}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // NAVIGATION BUTTON
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveNavigationScreen(
                      path: safePath,
                    ),
                  ),
                );
              },
              child: const Text("Start Navigation"),
            ),
          ),
        ],
      ),

      // NAV BAR)
      bottomNavigationBar: Container(
        height: 80,
        color: const Color(0xFF1B5E20),
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

  // NAV ITEM
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
              color: isSelected ? Colors.white : Colors.white60),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 11)),
        ],
      ),
    );
  }
}