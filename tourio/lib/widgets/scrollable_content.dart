import 'package:flutter/material.dart';

class ScrollableContent extends StatelessWidget {
  final String title;
  final String content;

  const ScrollableContent({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2), 
      body: SafeArea(
        child: Column(
          children: [
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "TOURIO",
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A3E2E),
                    ),
                  ),
                  Text(
                    "تــوريــو",
                    style: TextStyle(
                      fontFamily: 'Arabic',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A3E2E),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs (Etiquette | Culture | Phrases)
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF2E8E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/etiquette'),
                    child: const Text("Etiquette"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/culture'),
                    child: const Text("Culture"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/phrases'),
                    child: const Text("Phrases"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
