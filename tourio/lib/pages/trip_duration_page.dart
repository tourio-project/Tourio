import 'package:flutter/material.dart';

class TripDurationPage extends StatefulWidget {
  const TripDurationPage({super.key});

  @override
  State<TripDurationPage> createState() => _TripDurationPageState();
}

class _TripDurationPageState extends State<TripDurationPage> {
  // 1..30 (days)
  double _duration = 1;

  String _label(double v) {
    final d = v.round();
    if (d == 1) return '1 day';
    if (d >= 30) return '1 month';
    return '$d days';
  }

  void _goNext() {
    final prev = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final days = _duration.round();
   //Merge everything and add THIS page’s answer under the key the API expects with key 'days' 
    final nextArgs = {
      ...prev,      
      'days': days, 
    };

    Navigator.pushNamed(
      context,
      '/activities-per-day', // the page to choose 'options' per day
      arguments: nextArgs,
    );
  }

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF6D1F1F);
    const beige = Color(0xFFF3E8DE);
    const primary = Color(0xFFC03A2B);

    return Scaffold(
      backgroundColor: beige,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Help us plan your perfect trip — just a few quick questions!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: maroon),
              ),
              const SizedBox(height: 32),

              const Text(
                'What is the duration of your trip?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                ),
              ),
              const SizedBox(height: 24),

              // Days Slider 
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.black.withOpacity(0.75),
                  inactiveTrackColor: Colors.black.withOpacity(0.25),
                  thumbColor: primary,
                  overlayShape: SliderComponentShape.noOverlay,
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _duration,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  onChanged: (v) => setState(() => _duration = v),
                ),
              ),

              // Min / Max labels
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 day', style: TextStyle(color: maroon)),
                  Text('1 month', style: TextStyle(color: maroon)),
                ],
              ),
              const SizedBox(height: 16),

              // Current value label
              Text(
                _label(_duration),
                style: const TextStyle(fontSize: 16, color: maroon),
              ),

              const Spacer(),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('BACK'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: const BorderSide(color: primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _goNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('NEXT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
