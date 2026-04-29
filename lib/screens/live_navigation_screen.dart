import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'feedback_screen.dart';
import 'home_screen.dart'; 

class LiveNavigationScreen extends StatefulWidget {
  final List path;

  const LiveNavigationScreen({
    super.key,
    required this.path,
  });

  @override
  State<LiveNavigationScreen> createState() => _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends State<LiveNavigationScreen> {

  int currentIndex = 0;
  double progress = 0;
  Timer? timer;
  final FlutterTts tts = FlutterTts();

  bool isPaused = false;

  // SAFE BACK
  void goBack() {
    timer?.cancel();
    tts.stop();

    if (Navigator.canPop(context)) {
      Navigator.pop(context); // ✅ previous screen
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  List<Map<String, dynamic>> get safePath {
    try {
      return widget.path
          .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> get currentStep {
    if (safePath.isEmpty) return {};
    return safePath[currentIndex];
  }

  String getInstruction() {
    final text = currentStep['text']?.toString() ?? "Move forward";
    final distance = currentStep['distance']?.toString();

    return (distance != null && distance.isNotEmpty)
        ? "$text ($distance)"
        : text;
  }

  IconData getDirectionIcon(String text) {
    final t = text.toLowerCase();

    if (t.contains("left")) return Icons.turn_left;
    if (t.contains("right")) return Icons.turn_right;
    if (t.contains("straight")) return Icons.arrow_upward;

    return Icons.navigation;
  }

  int getDurationFromDistance(dynamic distance) {
    if (distance == null) return 2;

    final meters = int.tryParse(
      distance.toString().replaceAll(RegExp(r'[^0-9]'), ''),
    ) ?? 10;

    return (meters / 1.2).ceil();
  }

  Future speak() async {
    await tts.stop();
    await tts.speak(getInstruction());
  }

  @override
  void initState() {
    super.initState();

    if (safePath.isNotEmpty) {
      startStep();
    }
  }

  void startStep() {
    if (!isPaused) speak();

    final duration = getDurationFromDistance(currentStep['distance']);
    int ticks = (duration * 10).clamp(20, 1000);

    timer = Timer.periodic(const Duration(milliseconds: 100), (t) {

      if (isPaused) return;

      setState(() {
        progress += 1 / ticks;
      });

      if (progress >= 1) {
        t.cancel();

        if (currentIndex < safePath.length - 1) {
          setState(() {
            currentIndex++;
            progress = 0;
          });

          startStep();
        } else {
          // FINISH → FEEDBACK
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FeedbackScreen(),
              ),
            );
          });
        }
      }
    });
  }

  void pauseNavigation() {
    setState(() {
      isPaused = true;
    });
  }

  void resumeNavigation() {
    setState(() {
      isPaused = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (safePath.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("❌ No path data")),
      );
    }

    return Scaffold(
      body: Column(
        children: [

          // HEADER + BACK
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            color: const Color(0xFF1B5E20),
            child: Column(
              children: [

                // BACK BUTTON
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: goBack,
                    ),
                  ],
                ),

                const Text(
                  "Live Navigation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // PAUSE / RESUME
                ElevatedButton.icon(
                  onPressed: isPaused ? resumeNavigation : pauseNavigation,
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  label: Text(isPaused ? "Continue" : "Stop"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // STEP CARD
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  getDirectionIcon(currentStep['text']?.toString() ?? ""),
                  color: Colors.green,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    getInstruction(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ANIMATION
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [

                  Container(
                    width: 6,
                    height: 350,
                    color: Colors.grey.shade300,
                  ),

                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 6,
                      height: 350 * progress,
                      color: Colors.red,
                    ),
                  ),

                  Positioned(
                    bottom: 350 * progress,
                    child: const Icon(
                      Icons.directions_walk,
                      size: 35,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}