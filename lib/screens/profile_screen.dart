import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'login.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final user = FirebaseAuth.instance.currentUser;
  File? image;

  String getUserName(String email) {
    return email.split('@')[0];
  }

  String getRole(String email) {
    if (email.contains("students")) return "Student";
    if (email.contains("lecturers")) return "Lecturer";
    if (email.contains("admins")) return "Admin";
    return "User";
  }

  // PICK IMAGE
  Future pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    String email = user?.email ?? "No Email";
    String name = getUserName(email);
    String role = getRole(email);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F0EC),

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF1B5E20),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            // PROFILE IMAGE
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: image != null ? FileImage(image!) : null,
                child: image == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Tap to change photo",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // INFO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [

                  _tile("User Name", name),
                  const Divider(),

                  _tile("Campus Email", email),
                  const Divider(),

                  _tile("Role", role),
                ],
              ),
            ),

            const Spacer(),

            // LOGOUT 
            ElevatedButton.icon(
              onPressed: () async {

                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                // CLEAR STACK + GO LOGIN
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, String value) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}