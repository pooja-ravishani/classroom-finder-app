import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'map_screen.dart';
import 'building_screen.dart';
import 'favourite_screen.dart';
import 'navigation_screen.dart';
import 'schedule_screen.dart';
import 'report_issue_screen.dart';

class RoomDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const RoomDetailsScreen({super.key, required this.data});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {

  int navIndex = -1;

  void goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // FLOOR FORMAT FUNCTION
  String formatFloor(dynamic floor) {
    if (floor == null) return "";

    int f = int.tryParse(floor.toString()) ?? -1;

    if (f == 0) {
      return "Ground Floor";
    } else if (f > 0) {
      return "Floor $f";
    } else {
      return floor.toString();
    }
  }

  @override
  Widget build(BuildContext context) {

    final data = widget.data;
    final List facilities = data['facilities'] ?? [];

    final List<Map<String, dynamic>> path =
        (data['path'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE3F0EC),

      body: Column(
        children: [

          // HEADER
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
            child: Row(
              children: [

                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: goBack,
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      data['room'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 50),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  // INFO CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow("Building", data['building'] ?? ''),

                        // UPDATED FLOOR DISPLAY
                        _infoRow("Floor", formatFloor(data['floor'])),

                        _infoRow("Capacity", data['capacity'].toString()),

                        const SizedBox(height: 10),
                        Container(height: 1, color: Colors.grey.shade300),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // FACILITIES
                  if (facilities.isNotEmpty)
                    Wrap(
                      spacing: 20,
                      runSpacing: 15,
                      alignment: WrapAlignment.center,
                      children: facilities.map<Widget>((f) {
                        return _facilityItem(f);
                      }).toList(),
                    ),

                  const SizedBox(height: 30),

                  _btn(context, "Get Directions", Colors.green,
                      Icons.navigation, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NavigationScreen(
                          roomName: data['room'] ?? '',
                          path: path,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  _btn(context, "View on Map", Colors.green,
                      Icons.location_on, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(data: data),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  _btn(context, "View Schedule", const Color(0xFF1B5E20),
                      Icons.schedule, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScheduleScreen(
                          roomId: data['room'],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  _btn(context, "Report Issue", Colors.red,
                      Icons.report, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportIssueScreen(
                          roomName: data['room'] ?? '',
                        ),
                      ),
                    );
                  }),
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

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text("$title : $value",
          style: const TextStyle(fontSize: 15)),
    );
  }

  Widget _facilityItem(String type) {
    final t = type.toLowerCase().replaceAll(" ", "");

    Icon icon;

    switch (t) {
      case "wifi":
        icon = const Icon(Icons.wifi, color: Colors.white);
        break;
      case "projector":
        icon = const Icon(Icons.tv, color: Colors.white);
        break;
      case "whiteboard":
        icon = const Icon(Icons.dashboard_customize, color: Colors.white);
        break;
      case "ac":
        icon = const Icon(Icons.ac_unit, color: Colors.white);
        break;
      case "sound":
        icon = const Icon(Icons.volume_up, color: Colors.white);
        break;
      case "table":
      case "desk":
        icon = const Icon(Icons.table_restaurant, color: Colors.white);
        break;
      case "computer":
      case "pc":
        icon = const Icon(Icons.computer, color: Colors.white);
        break;
      default:
        icon = const Icon(Icons.meeting_room, color: Colors.white);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: icon,
        ),
        const SizedBox(height: 6),
        Text(type),
      ],
    );
  }

  Widget _btn(BuildContext context, String text, Color color, IconData icon,
      {VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(text,
            style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
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
              color: isSelected ? Colors.white : Colors.white60),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60)),
        ],
      ),
    );
  }
}