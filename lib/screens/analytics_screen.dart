import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  int totalRooms = 0;
  int totalLabs = 0;
  int totalOffices = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // LOAD DATA
  Future<void> loadData() async {

    var snapshot =
        await FirebaseFirestore.instance.collection("classrooms").get();

    for (var doc in snapshot.docs) {
      String type = doc['type'] ?? "room";

      if (type == "room") totalRooms++;
      if (type == "lab") totalLabs++;
      if (type == "office") totalOffices++;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F0),

      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: const Color(0xFF1B5E20),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // TOP CARDS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _card("Rooms", totalRooms, Icons.meeting_room),
                _card("Labs", totalLabs, Icons.computer),
                _card("Offices", totalOffices, Icons.apartment),
              ],
            ),

            const SizedBox(height: 30),

            // PIE CHART 
            _sectionTitle("Space Distribution"),

            const SizedBox(height: 10),

            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: [
                    _pie(totalRooms, "Rooms"),
                    _pie(totalLabs, "Labs"),
                    _pie(totalOffices, "Offices"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // SUMMARY
            _sectionTitle("Summary"),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _row("Total Rooms", totalRooms),
                  _row("Total Labs", totalLabs),
                  _row("Total Offices", totalOffices),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CARD
  Widget _card(String title, int value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF006940),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 5),
            Text("$value",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // PIE
  PieChartSectionData _pie(int value, String title) {
    return PieChartSectionData(
      value: value.toDouble(),
      title: "$title\n$value",
      radius: 60,
    );
  }

  // TITLE
  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  // ROW
  Widget _row(String title, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text("$value"),
        ],
      ),
    );
  }
}