import 'package:flutter/material.dart';

class TripActivity {
  final String title;
  final String time;
  final String duration;
  final String transport;
  final String price;
  final IconData icon;

  TripActivity({
    required this.title,
    required this.time,
    required this.duration,
    required this.transport,
    required this.price,
    required this.icon,
  });
}