import 'package:flutter/material.dart';
import '../widgets/slideshow_background.dart';
import '../widgets/tourio_logo.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SlideshowBackground(
        interval: Duration(seconds: 1),
        fadeDuration: Duration(milliseconds: 400),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 16),
              TourioLogo(width: 280),
            ],
          ),
        ),
      ),
    );
  }
}
