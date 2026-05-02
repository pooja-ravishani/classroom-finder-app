import 'package:flutter/material.dart';
import 'login.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SizedBox.expand(
        child: Column(
          children: [

            //TOP SECTION
            Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              child: Column(
                children: [
                  //LOGO
                  Image.asset('assets/logo.png', height: 90),

                  const SizedBox(height: 15),

                 

                  //BIG TITLE
                  const Text(
                    "Smart Classroom\nFinder",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28, // 🔥 bigger
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
            ),

            //IMAGE + CONTENT
            Expanded(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [

                  Positioned.fill(
                    child: Image.asset(
                      'assets/background.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  //FADE EFFECT
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white70,
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  Column(
                    children: [

                      const SizedBox(height: 25),

                      // SUBTEXT
                      const Text(
                        "Find classrooms easily at NSBM\nUniversity",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17, 
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // BUTTON
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 55, 
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006940),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}