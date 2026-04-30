import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

//ML KIT
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;

// SOUND + VIBRATION
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

// NAV IMPORTS
import 'home_screen.dart';
import 'search_screen.dart';
import 'map_screen.dart';
import 'building_screen.dart';
import 'favourite_screen.dart';

import 'room_details.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {

  final MobileScannerController controller = MobileScannerController();
  final AudioPlayer player = AudioPlayer();

  int _selectedIndex = 2;
  bool isScanned = false;

  // BACK FUNCTION
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

  // Sound
  Future<void> playFeedback() async {
    try {
      await player.play(AssetSource('sounds/beep.mp3'));

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 150);
      }
    } catch (e) {
      debugPrint("Feedback error: $e");
    }
  }

  // HANDLE QR
  Future<void> handleQR(String code) async {

    await playFeedback();

    String roomId = code.replaceAll("room:", "");

    var query = await FirebaseFirestore.instance
        .collection("classrooms")
        .where("room", isEqualTo: roomId)
        .get();

    if (query.docs.isNotEmpty) {

      var data = query.docs.first.data();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoomDetailsScreen(data: data),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Room not found")),
      );

      isScanned = false;
      controller.start();
    }
  }

  // GALLERY SCAN
  Future<void> scanFromGallery() async {

    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final inputImage =
        mlkit.InputImage.fromFilePath(pickedFile.path);

    final barcodeScanner = mlkit.BarcodeScanner();

    final List<mlkit.Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {

      final String? code = barcodes.first.rawValue;

      if (code != null) {
        await handleQR(code);
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No QR found in image")),
      );
    }

    barcodeScanner.close();
  }

  @override
  void dispose() {
    controller.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // APPBAR WITH BACK
      appBar: AppBar(
        title: const Text("QR Scanner"),
        backgroundColor: const Color(0xFF1B5E20),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: scanFromGallery,
          ),
        ],
      ),

      body: Stack(
        children: [

          MobileScanner(
            controller: controller,
            onDetect: (barcodeCapture) async {

              if (isScanned) return;

              final barcodes = barcodeCapture.barcodes;

              if (barcodes.isEmpty) return;

              final code = barcodes.first.rawValue;

              if (code != null) {

                isScanned = true;
                controller.stop();

                await handleQR(code);
              }
            },
          ),

          // SCAN BOX
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Scan QR or pick from gallery",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
            _nav(Icons.home, "Home", 0),
            _nav(Icons.search, "Search", 1),
            _nav(Icons.map, "Map", 2),
            _nav(Icons.business, "Buildings", 3),
            _nav(Icons.favorite, "Favorites", 4),
          ],
        ),
      ),
    );
  }

  Widget _nav(IconData icon, String label, int index) {
    bool isSelected = index == _selectedIndex;

    return GestureDetector(
      onTap: () {

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
              MaterialPageRoute(builder: (_) => const QRScannerScreen()));
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
              color: isSelected ? Colors.white : Colors.white60),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60)),
        ],
      ),
    );
  }
}