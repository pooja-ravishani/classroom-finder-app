import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {

  String selectedFilter = "all";
  final Color mainGreen = const Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFE3F0EC),

      appBar: AppBar(
        title: const Text("Admin - Reports"),
        backgroundColor: mainGreen,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reports")
            .orderBy("timestamp", descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          int pending = docs.where((d) => d['status'] == "pending").length;
          int resolved = docs.where((d) => d['status'] == "resolved").length;

          var filteredDocs = docs.where((d) {
            String status = d['status'] ?? "pending";

            if (selectedFilter == "all") return true;
            if (selectedFilter == "pending") return status == "pending";
            if (selectedFilter == "resolved") return status == "resolved";

            return true;
          }).toList();

          return Column(
            children: [

              //PIE CHART
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 45,
                      sections: [
                        PieChartSectionData(
                          value: pending.toDouble(),
                          color: Colors.orange,
                          title: "$pending",
                          radius: 55,
                          titleStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: resolved.toDouble(),
                          color: Colors.green,
                          title: "$resolved",
                          radius: 55,
                          titleStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //LEGEND
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Legend(color: Colors.orange, text: "Pending"),
                  SizedBox(width: 20),
                  _Legend(color: Colors.green, text: "Resolved"),
                ],
              ),

              const SizedBox(height: 10),

              //FILTER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _filterChip("All"),
                  _filterChip("Pending"),
                  _filterChip("Resolved"),
                ],
              ),

              const SizedBox(height: 10),

              //LIST
              Expanded(
                child: filteredDocs.isEmpty
                    ? const Center(child: Text("No Reports Found"))
                    : ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {

                          var d = filteredDocs[index];
                          String status = d['status'] ?? "pending";

                          Color statusColor =
                              status == "resolved" ? Colors.green : Colors.orange;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                )
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  children: [

                                    CircleAvatar(
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        (d['room'] ?? "R")[0],
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            "${d['room']} - ${d['issue']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(d['description'] ?? ""),
                                        ],
                                      ),
                                    ),

                                    //SOLVE BUTTON
                                    if (status == "pending")
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, color: Colors.green),
                                        onPressed: () async {

                                          await FirebaseFirestore.instance
                                              .collection("reports")
                                              .doc(d.id)
                                              .update({
                                            "status": "resolved",
                                            "resolvedAt": FieldValue.serverTimestamp(),

                                            //NOTIFICATION FIELD
                                            "notified": false,
                                          });

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Resolved ✔")),
                                          );
                                        },
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                //STATUS CHIP
                                Row(
                                  children: [

                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    if (status == "resolved")
                                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // IMAGE PREVIEW
                                if (d['image'] != null && d['image'] != "")
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      d['image'],
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label) {
    bool isSelected = selectedFilter == label.toLowerCase();

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label.toLowerCase();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? mainGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: mainGreen),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : mainGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

//LEGEND
class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}