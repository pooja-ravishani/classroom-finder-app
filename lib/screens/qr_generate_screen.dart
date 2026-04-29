import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class QRGenerateScreen extends StatefulWidget {
  const QRGenerateScreen({super.key});

  @override
  State<QRGenerateScreen> createState() => _QRGenerateScreenState();
}

class _QRGenerateScreenState extends State<QRGenerateScreen> {

  final TextEditingController roomController = TextEditingController();
  String qrData = "";

  // SAVE 
  Future<void> saveQR() async {

    if (qrData.isEmpty) return;

    try {

      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: true,
      );

      final picData = await qrPainter.toImageData(300);

      if (picData == null) return;

      Uint8List bytes = picData.buffer.asUint8List();

      // DOWNLOADS FOLDER
      final directory = await getExternalStorageDirectory();
      final path = "${directory!.path}/${roomController.text}.png";

      final file = File(path);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved: $path")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR"),
        backgroundColor: const Color(0xFF1B5E20),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: roomController,
              decoration: InputDecoration(
                labelText: "Enter Room / Lab / Office",
                hintText: "e.g. A301",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (roomController.text.isEmpty) return;

                setState(() {
                  qrData = "room:${roomController.text.trim()}";
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006940),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Generate QR"),
            ),

            const SizedBox(height: 30),

            if (qrData.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: QrImageView(
                  data: qrData,
                  size: 220,
                ),
              ),

            const SizedBox(height: 20),

            if (qrData.isNotEmpty)
              ElevatedButton.icon(
                onPressed: saveQR,
                icon: const Icon(Icons.download),
                label: const Text("Save QR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}