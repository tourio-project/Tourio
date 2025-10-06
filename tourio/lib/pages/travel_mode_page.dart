import 'package:flutter/material.dart';

class TravelModePage extends StatefulWidget {
  const TravelModePage({super.key});

  @override
  State<TravelModePage> createState() => _TravelModePageState();
}

class _TravelModePageState extends State<TravelModePage> {
  
  static const cream = Color(0xFFF3E8DE);
  static const maroon = Color(0xFF5C1E16);
  static const accent = Color(0xFFC03A2B);
  static const chipBg = Color(0xFF2B0D0D);

  // These are the "moods"
  final List<String> _categories = const [
    'Calm',
    'Romantic',
    'Adventurous',
    'Spontaneous',
    'Festive',
    'Casual',
    'Exploratory',
    'Tired',
    'Cozy',
    'Hungry',
    'Curious',
    'Creative',
    'Bored',
  ];

  final Set<String> _selected = {};

  void _goNext() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick at least one mood')),
      );
      return;
    }

    // 1) Read whatever was passed from the previous page(s)
    final prev = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};

    // 2) Merge everything and add THIS page’s answer under the key the API expects with key 'moods' 
    final nextArgs = {
      ...prev,                      
      'moods': _selected.toList(), 
    };

   
    Navigator.pushNamed(
      context,
      '/trip-preferences',          
      arguments: nextArgs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 8),
              const Text(
                'Help us plan your perfect trip — just a few quick questions!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: maroon,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Discover mood',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: maroon,
                ),
              ),
              const SizedBox(height: 14),

              // Mood chips
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: _categories.map((label) {
                  final selected = _selected.contains(label);
                  return _CategoryPill(
                    label: label,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selected.remove(label);
                        } else {
                          _selected.add(label);
                        }
                      });
                    },
                  );
                }).toList(),
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

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const chipBg = Color(0xFF2B0D0D);
  static const maroon = Color(0xFF5C1E16);
  static const accent = Color(0xFFC03A2B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        splashColor: Colors.white24,
        child: AnimatedScale(
          scale: selected ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? accent : chipBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.white : maroon.withOpacity(0.35),
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: accent.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(Icons.check, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
