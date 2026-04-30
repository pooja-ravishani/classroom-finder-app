import 'package:flutter/material.dart';
import 'navigation_screen.dart';

// NAV IMPORTS
import 'home_screen.dart';
import 'search_screen.dart';
import 'building_screen.dart';
import 'favourite_screen.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const MapScreen({
    super.key,
    required this.data,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  final TransformationController _controller = TransformationController();
  int _selectedIndex = -1;

  // BACK
  void goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    const double imgWidth = 1024;
    const double imgHeight = 1536;

    final roomName = widget.data['room'] ?? "";
    final double x = (widget.data['x'] ?? 0).toDouble();
    final double y = (widget.data['y'] ?? 0).toDouble();

    final List<Map<String, dynamic>> path =
        (widget.data['path'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    return Scaffold(
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
                    "Campus Map",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Positioned(
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: goBack,
                  ),
                ),
              ],
            ),
          ),

          // MAP
          Expanded(
            child: ClipRect(
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1,
                maxScale: 4,
                alignment: Alignment.topLeft,

                child: GestureDetector(
                  onTapUp: (details) {
                    // TAP POSITION
                    final tapped = details.localPosition;

                    // SCALE FIX
                    final matrix = _controller.value;
                    final scale = matrix.getMaxScaleOnAxis();

                    final offsetX = matrix.storage[12];
                    final offsetY = matrix.storage[13];

                    final realX = (tapped.dx - offsetX) / scale;
                    final realY = (tapped.dy - offsetY) / scale;

                    // PRINT TO TERMINAL
                    debugPrint("📍 X: ${realX.toStringAsFixed(1)}, Y: ${realY.toStringAsFixed(1)}");
                  },

                  child: Stack(
                    children: [

                      SizedBox(
                        width: imgWidth,
                        height: imgHeight,
                        child: Image.asset(
                          'assets/map.png',
                          fit: BoxFit.fill,
                        ),
                      ),

                      // PIN
                      Positioned(
                        left: x,
                        top: y,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 60,
                              color: Colors.red,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                roomName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CARD
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  roomName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NavigationScreen(
                                            roomName: roomName,
                                            path: path,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Get Directions"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const SearchScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => MapScreen(data: {})));
        } else if (index == 3) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const BuildingScreen()));
        } else if (index == 4) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const FavouriteScreen()));
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