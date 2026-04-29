import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// NAV IMPORTS
import 'home_screen.dart';
import 'search_screen.dart';
import 'map_screen.dart';
import 'building_screen.dart';
import 'favourite_screen.dart';

class ReportIssueScreen extends StatefulWidget {
  final String roomName;

  const ReportIssueScreen({super.key, required this.roomName});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {

  final Color mainGreen = const Color(0xFF1B5E20);

  String selectedIssue = "Room not found";
  final TextEditingController controller = TextEditingController();

  File? image;
  bool isLoading = false;

  int _selectedIndex = -1;

  final List<String> issues = [
    "Room not found",
    "Equipment not working",
    "Door / Access issue",
    "Wrong room info",
    "Cleanliness issue",
    "Other",
  ];

  // BACK
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

  // PICK IMAGE
  Future pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  void showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> uploadImage() async {
    if (image == null) return null;

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance
        .ref()
        .child("reports/$fileName.jpg");

    await ref.putFile(image!);

    return await ref.getDownloadURL();
  }

  Future submitReport() async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe the issue")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl = await uploadImage();

      await FirebaseFirestore.instance.collection("reports").add({
        "room": widget.roomName,
        "issue": selectedIssue,
        "description": controller.text,
        "image": imageUrl,
        "status": "pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report Submitted ✅")),
      );

      goBack();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFE3F0EC),

      body: Column(
        children: [

          // HEADER + BACK
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
                      "Report Issue - ${widget.roomName}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 50),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  ...issues.map((issue) {
                    return Card(
                      child: RadioListTile(
                        value: issue,
                        groupValue: selectedIssue,
                        activeColor: mainGreen,
                        onChanged: (value) {
                          setState(() {
                            selectedIssue = value.toString();
                          });
                        },
                        title: Text(issue),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 15),

                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Describe the issue...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: showPicker,
                    child: Container(
                      width: double.infinity,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.camera_alt, size: 30),
                                SizedBox(height: 5),
                                Text("Add Photo"),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(image!, fit: BoxFit.cover),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainGreen,
                      ),
                      onPressed: isLoading ? null : submitReport,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Submit Report"),
                    ),
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
                  color: isSelected ? Colors.white : Colors.white60)),
        ],
      ),
    );
  }
}