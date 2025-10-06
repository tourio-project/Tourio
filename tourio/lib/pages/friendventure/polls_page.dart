import 'package:flutter/material.dart';
import '../../widgets/tourio_logo.dart';
import '../../utils/navigation_utils.dart';

class PollsPage extends StatelessWidget {
  const PollsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E8C7), Color(0xFFF8EDEB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF5C1E16), size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TourioLogo(width: 180),
                      const SizedBox(height: 20),
                      const Text(
                        'Trip Polls',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5C1E16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Vote on your group’s trip plans',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC03A2B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'CREATE NEW POLL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildPollCard(
                              context,
                              question: 'Where should we go in Jordan?',
                              options: ['Petra', 'Wadi Rum', 'Amman'],
                              votes: [5, 3, 2],
                            ),
                            _buildPollCard(
                              context,
                              question: 'What activity for Day 1?',
                              options: ['Hiking', 'Cultural Tour', 'Relaxation'],
                              votes: [4, 4, 1],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, 2),
    );
  }

  Widget _buildPollCard(
    BuildContext context, {
    required String question,
    required List<String> options,
    required List<int> votes,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C1E16),
              ),
            ),
            const SizedBox(height: 10),
            ...options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              int voteCount = votes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(option,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF5C1E16))),
                    ),
                    Text('$voteCount votes',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF8B4513))),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.how_to_vote, color: Color(0xFFC03A2B)),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}