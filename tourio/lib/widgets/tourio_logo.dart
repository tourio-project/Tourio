import 'package:flutter/material.dart';

class TourioLogo extends StatelessWidget {
  const TourioLogo({super.key, this.width = 260, this.dy = 0});
  final double width;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Image.asset(
          'assets/images/star.jpg',
          width: width,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}