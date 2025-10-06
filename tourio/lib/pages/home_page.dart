import 'package:flutter/material.dart';
import '../widgets/tourio_logo.dart';
import '../widgets/culture_row.dart';
import '../utils/navigation_utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF5C1E16);
    const beige = Color(0xFFF3E8DE);

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child:
                Image.asset('assets/images/petra_image.jpg', fit: BoxFit.cover),
          ),
          const SafeArea(
            child: Column(
              children: [
                SizedBox(height: 16),
                TourioLogo(width: 230),
              ],
            ),
          ),
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 14),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Discover Jordan with intelligence',
                      style: TextStyle(
                        fontFamily: 'ArefRuqaaInk',
                        fontSize: 28,
                        color: maroon,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Start planning your trip with AI!',
                      style: TextStyle(
                        fontFamily: 'ArefRuqaaInk',
                        fontSize: 18,
                        color: Color(0xFFA7332A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/travel-mode');
                      },
                      child: Container(
                        width: 300,
                        height: 90,
                        decoration: BoxDecoration(
                          color: beige,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3)),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/shape.jpg',
                            width: 38,
                            height: 38,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Happening Now',
                      style: TextStyle(
                        fontFamily: 'ArefRuqaaInk',
                        fontSize: 28,
                        color: maroon,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<dynamic>>(
                    future: fetchTrendingEvents(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else {
                        final events = snapshot.data!;
                        return SizedBox(
                          height:
                              150, // adjust to match your EventRow card height
                          child: ListView.builder(
                            scrollDirection: Axis
                                .horizontal, // to keep it like your Figma row
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return Container(
                                width: 200,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event['Title'] ?? "No Title",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(event['Date'] ?? "No Date"),
                                      Text(event['Location'] ?? "No Location"),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Explore the culture',
                      style: TextStyle(
                        fontFamily: 'ArefRuqaaInk',
                        fontSize: 28,
                        color: maroon,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const CultureRow(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, 0),
    );
  }
}

Future<List<Map<String, dynamic>>> fetchTrendingEvents() async {
  // iOS Simulator / macOS app: 127.0.0.1 is OK while the FastAPI runs on Mac.
  // Android emulator: use http://10.0.2.2:8000
  // Physical device: use your Mac’s LAN IP, e.g., http://192.168.1.23:8000
  const baseUrl = 'http://127.0.0.1:8000/trending';

  final res = await http.get(Uri.parse(baseUrl));
  if (res.statusCode != 200) {
    throw Exception('Failed to load events: ${res.statusCode}');
  }
  final decoded = json.decode(res.body) as Map<String, dynamic>;
  final list = (decoded['events'] as List).cast<Map<String, dynamic>>();
  return list;
}
