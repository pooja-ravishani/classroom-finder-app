import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';


import 'home_screen.dart';
import 'search_screen.dart';
import 'map_screen.dart';
import 'building_screen.dart';
import 'favourite_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final String roomId;

  const ScheduleScreen({super.key, required this.roomId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {

  final Color mainGreen = const Color(0xFF1B5E20);

  DateTime selectedDate = DateTime.now();
  DateTime currentTime = DateTime.now();

  Timer? timer;
  int _selectedIndex = -1;

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

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  double getNowInDouble() {
    return currentTime.hour + (currentTime.minute / 60);
  }

  String getStatus(double start, double end) {

    double now = getNowInDouble();

    if (now < start) return "next";
    if (now >= start && now <= end) return "ongoing";
    return "done";
  }

  @override
  Widget build(BuildContext context) {

    bool todaySelected = isToday(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('classrooms')
            .where('room', isEqualTo: widget.roomId)
            .get(),

        builder: (context, roomSnapshot) {

          if (!roomSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var roomDoc = roomSnapshot.data!.docs.first;

          return Column(
            children: [

              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                decoration: BoxDecoration(
                  color: mainGreen,
                  borderRadius: const BorderRadius.only(
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
                          "Schedule ${widget.roomId}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(width: 50),
                  ],
                ),
              ),

              // TODAY LABEL
              if (todaySelected)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "Today",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              _monthHeader(),
              _calendarGrid(),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('classrooms')
                      .doc(roomDoc.id)
                      .collection('schedules')
                      .snapshots(),

                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var docs = snapshot.data!.docs;

                    docs.sort((a, b) =>
                        double.parse(a['start'].toString())
                            .compareTo(double.parse(b['start'].toString())));

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {

                        var d = docs[index];

                        double start = double.parse(d['start'].toString());
                        double end = double.parse(d['end'].toString());

                        String status = getStatus(start, end);

                        return _card(d, status, todaySelected);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: Container(
        height: 80,
        color: mainGreen,
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

  Widget _card(QueryDocumentSnapshot d, String status, bool showStatus) {

    Color color = Colors.grey;
    String label = "";

    if (showStatus) {
      if (status == "ongoing") {
        color = Colors.orange; 
        label = "ONGOING";
      } else if (status == "next") {
        color = Colors.blue; 
        label = "NEXT";
      } else {
        color = Colors.red; 
        label = "DONE";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: showStatus ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: showStatus ? color : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d['time']),
              if (showStatus)
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 8),

          Text(d['subject'],
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          Text(d['lecturer']),
        ],
      ),
    );
  }

  Widget _monthHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        "${_monthName(selectedDate.month)} ${selectedDate.year}",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _calendarGrid() {
    int totalDays =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalDays,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {

        int day = index + 1;

        DateTime d =
            DateTime(selectedDate.year, selectedDate.month, day);

        bool isSelected = d.day == selectedDate.day;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = d;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "$day",
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
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
              color: isSelected ? Colors.white : Colors.white60),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60)),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return months[m - 1];
  }
}