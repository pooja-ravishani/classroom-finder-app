import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'map_screen.dart';
import 'building_screen.dart';
import 'favourite_screen.dart';
import 'room_details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final Color deepGreen = const Color(0xFF1B5E20);
  final Color mediumGreen = const Color(0xFF006940);

  int selectedTab = 0;
  int navIndex = 1;

  String searchText = "";
  TextEditingController controller = TextEditingController();

  List<String> recent = [];

  String getType() {
    if (selectedTab == 0) return "room";
    if (selectedTab == 1) return "lab";
    return "office";
  }

  void addRecent(String value) {
    if (value.isEmpty) return;

    setState(() {
      recent.remove(value);
      recent.insert(0, value);

      if (recent.length > 5) {
        recent.removeLast();
      }
    });
  }

  // SAFE BACK FUNCTION
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
      body: Column(
        children: [

          // 🔥 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: BoxDecoration(
              color: deepGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [

                const SizedBox(width: 15),

                // FIXED BACK BUTTON
                GestureDetector(
                  onTap: goBack,
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),

                const Spacer(),

                const Text(
                  "Search",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
                ),

                const Spacer(),
                const SizedBox(width: 40),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TABS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _tab("Rooms", 0),
                const SizedBox(width: 10),
                _tab("Labs", 1),
                const SizedBox(width: 10),
                _tab("Offices", 2),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: controller,
              onChanged: (val) {
                setState(() {
                  searchText = val.toLowerCase();
                });
              },
              onSubmitted: (val) {
                addRecent(val);
              },
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // DATA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('classrooms')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs.where((doc) {

                  final data = doc.data() as Map<String, dynamic>;

                  String type = data['type'] ?? '';
                  String room = data['room'].toString().toLowerCase();
                  String building = data['building'].toString().toLowerCase();

                  return type == getType() &&
                      (room.contains(searchText) ||
                       building.contains(searchText));

                }).toList();

                if (searchText.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        "Recent Searches",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        )
                      ),
                      const SizedBox(height: 10),

                      if (recent.isEmpty)
                        const Text("No recent searches"),

                      ...recent.map((e) => _recentTile(e)).toList(),
                    ],
                  );
                }

                if (docs.isEmpty) {
                  return const Center(child: Text("No results found"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    var data = docs[index].data() as Map<String, dynamic>;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.location_on,
                            color: Colors.green),

                        title: Text(data['room'] ?? ''),
                        subtitle: Text(
                          "${data['building']} - Floor ${data['floor']}"
                        ),

                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),

                        onTap: () {
                          addRecent(data['room']);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RoomDetailsScreen(data: data),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // NAV BAR
          Container(
            height: 80,
            color: deepGreen,
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
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = navIndex == index;

    return GestureDetector(
      onTap: () {

        setState(() {
          navIndex = index;
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
              color: isSelected ? Colors.white : Colors.white54,
              size: 28),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String text, int index) {
    bool isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? mediumGreen : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentTile(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        setState(() {
          controller.text = title;
          searchText = title.toLowerCase();
        });
      },
    );
  }
}