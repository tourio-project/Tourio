import 'package:flutter/material.dart';

class ActivitiesPerDayPage extends StatefulWidget {
  const ActivitiesPerDayPage({super.key});

  @override
  State<ActivitiesPerDayPage> createState() => _ActivitiesPerDayPageState();
}

class _ActivitiesPerDayPageState extends State<ActivitiesPerDayPage> {
  
  static const cream = Color(0xFFF3E8DE);
  static const maroon = Color(0xFF5C1E16);
  static const dark = Color(0xFF2B0D0D);
  static const accent = Color(0xFFC03A2B);

  double _activities = 1; 

  void _goNext() {
    // 1) Read everything from prior pages
    final prev = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};

    // 2) Merge & set the API key expected by FastAPI: 'options'
    final nextArgs = {
      ...prev,
      'options': _activities.round(), 
    };

    Navigator.pushNamed(
      context,
      '/group-size',
      arguments: nextArgs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
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
                style: TextStyle(
                  fontSize: 16,
                  color: maroon,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'What is the average number of activities\nper day ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 28),

              
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: dark,
                  inactiveTrackColor: dark,
                  trackHeight: 16,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbColor: accent,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 12),
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                ),
                child: Slider(
                  value: _activities,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => setState(() => _activities = v),
                ),
              ),

              
              const SizedBox(height: 6),
              Text(
                _activities.round().toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: maroon,
                  fontWeight: FontWeight.w600,
                ),
              ),

              
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1', style: TextStyle(color: maroon)),
                  Text('10', style: TextStyle(color: maroon)),
                ],
              ),

              const Spacer(),

              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('BACK'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: const BorderSide(color: accent, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
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
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
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
