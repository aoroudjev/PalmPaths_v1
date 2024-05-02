import 'dart:io';
import 'package:flutter/material.dart';
import 'package:static_image_test/ui/detection_widget.dart';
import 'package:static_image_test/ui/history_widget.dart';


class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDAD3C1),
      appBar: AppBar(
        title: const Text('Main Menu'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main logo
            Image.asset(
              'assets/images/hand_logo_large.png',
              height: 350,
            ),
            const SizedBox(
              height: 50,
            ),
            // Buttons with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DetectorWidget()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                  backgroundColor: Color(0xFF918B7D),
                  elevation: 10,
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 30, color: Color(0xFF1D1B17)),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                  backgroundColor: Color(0xFF918B7D),
                  elevation: 10,
                ),
                child: const Text(
                  'History',
                  style: TextStyle(fontSize: 30, color: Color(0xFF1D1B17)),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                  backgroundColor: Color(0xFF918B7D),
                  elevation: 10,
                ),
                child: const Text(
                  'Quit',
                  style: TextStyle(fontSize: 30, color: Color(0xFF1D1B17)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}