import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin_reports_screen.dart';
import 'qr_generate_screen.dart';
import 'view_feedback_screen.dart';
import 'analytics_screen.dart';
import 'login.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  final Color mainGreen = const Color(0xFF1B5E20);
  final Color cardGreen = const Color(0xFF006940);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F0),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: mainGreen,
        centerTitle: true,

        //LOGOUT BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {

              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: [

            //REPORTS
            _card(
              "Reports",
              Icons.report,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminReportsScreen(),
                  ),
                );
              },
            ),

            //GENERATE QR
            _card(
              "Generate QR",
              Icons.qr_code,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QRGenerateScreen(),
                  ),
                );
              },
            ),

            //ANALYTICS (UPDATED)
            _card(
              "Analytics",
              Icons.bar_chart,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnalyticsScreen(),
                  ),
                );
              },
            ),

            //VIEW FEEDBACK
            _card(
              "View Feedback",
              Icons.feedback,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ViewFeedbackScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //CARD WIDGET
  Widget _card(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}