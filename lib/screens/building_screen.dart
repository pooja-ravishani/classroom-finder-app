import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'room_details.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import 'map_screen.dart';
import 'favourite_screen.dart';

class BuildingScreen extends StatefulWidget {
  const BuildingScreen({super.key});

  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {

  int _selectedIndex = 3;

  String? selectedBuilding;
  int? selectedFloor;

  final List<String> buildings = [
    "Faculty of Computing",
    "Faculty of Engineering",
    "Faculty of Business",
    "Administration",
    "Library",
  ];

  final List<Map<String, dynamic>> floors = [
    {"label": "Ground Floor", "value": 0},
    {"label": "Floor 1", "value": 1},
    {"label": "Floor 2", "value": 2},
    {"label": "Floor 3", "value": 3},
  ];

  // BACK FUNCTION
  void goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // 🔥 previous screen
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F0EC),

      body: Column(
        children: [

          // HEADER WITH BACK BUTTON
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [

                const Center(
                  child: Text(
                    "Buildings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // BACK BUTTON
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: goBack,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  DropdownButtonFormField<String>(
                    decoration: _boxDecoration("Select Building"),
                    value: selectedBuilding,
                    items: buildings.map((b) {
                      return DropdownMenuItem(
                        value: b,
                        child: Text(b),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedBuilding = val;
                        selectedFloor = null;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  if (selectedBuilding != null)
                    DropdownButtonFormField<int>(
                      decoration: _boxDecoration("Select Floor"),
                      value: selectedFloor,
                      items: floors.map((f) {
                        return DropdownMenuItem<int>(
                          value: f['value'],
                          child: Text(f['label']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedFloor = val;
                        });
                      },
                    ),

                  const SizedBox(height: 20),

                  if (selectedBuilding != null && selectedFloor != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('classrooms')
                          .where('building', isEqualTo: selectedBuilding)
                          .where('floor', isEqualTo: selectedFloor)
                          .snapshots(),
                      builder: (context, snapshot) {

                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final docs = snapshot.data!.docs;

                        if (docs.isEmpty) {
                          return const Text("No rooms found");
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {

                            final data = docs[index];
                            final isFav = data['favorite'] ?? false;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 3,
                              child: ListTile(
                                title: Text(
                                  data['room'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Floor ${data['floor']}"),

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    IconButton(
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('classrooms')
                                            .doc(data.id)
                                            .update({
                                          'favorite': !isFav,
                                        });
                                      },
                                    ),

                                    const Icon(Icons.arrow_forward_ios, size: 16),
                                  ],
                                ),

                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RoomDetailsScreen(
                                        data: data.data() as Map<String, dynamic>,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
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

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {

        if (index == _selectedIndex) return;

        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
        if (index == 1) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const SearchScreen()));
        }
        if (index == 2) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => MapScreen(data: {})));
        }
        if (index == 3) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const BuildingScreen()));
        }
        if (index == 4) {
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _boxDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}