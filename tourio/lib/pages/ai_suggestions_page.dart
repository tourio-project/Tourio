import 'package:flutter/material.dart';
import '../services/api.dart' as api;

class AiSuggestionsPage extends StatefulWidget {
  const AiSuggestionsPage({super.key});

  @override
  State<AiSuggestionsPage> createState() => _AiSuggestionsPageState();
}

class _AiSuggestionsPageState extends State<AiSuggestionsPage> {
  bool _loading = true;
  String? _error;

  int _selectedDay = 0;
  int _days = 1;
  int _options = 3;

  /// rec[dayIndex] => List<location maps>
  List<List<Map<String, dynamic>>> _rec = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  
  List<String> _toStringList(dynamic v, [List<String> fallback = const []]) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return fallback;
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};

    final moods =
        _toStringList(args['moods'], const ['Adventurous', 'Curious']);
    final interests = _toStringList(
      args['interests'] ?? args['categories'],
      const ['Nature/Outdoors', 'Adventure'],
    );

    final days =
        (args['days'] ?? args['durationDays'] ?? args['duration'] ?? 2) as int;
    final options = (args['options'] ?? args['activitiesPerDay'] ?? 3) as int;
    final budget = (args['budget'] ?? args['budgetTotalJD'] ?? 200) as int;
    final city = (args['city'] ?? 'Amman').toString();

    try {
      final prefs = api.AiPrefs(
        moods: moods,
        budget: budget,
        interests: interests,
        days: days,
        options: options,
        city: city,
      );

      final res = await api.ApiService.getRecommendations(prefs);

      if (!mounted) return;
      setState(() {
        _rec = res.rec
            .map((day) => day.map((e) => Map<String, dynamic>.from(e)).toList())
            .toList();
        _days = _rec.isNotEmpty ? _rec.length : days;
        _options = options;
        _selectedDay = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _saveAndContinue() {
    // Convert current _rec into the TripPlan map
    final tripMap = {
      'members': [
        {'name': 'You'},
        {'name': 'Sara'},
        {'name': 'Omar'},
      ],
      'days': List.generate(_rec.length, (i) {
        return {
          'title': 'Day ${i + 1}',
          'activities': _rec[i].map((loc) {
            return {
              'time': (loc['time'] ?? '').toString(),
              'duration': (loc['duration'] ?? '').toString(),
              'title': (loc['name'] ?? 'Activity').toString(),
              'location': (loc['city'] ?? 'Jordan').toString(),
              'transport': (loc['transport'] ?? 'Car').toString(),
              'cost': (loc['cost'] != null) ? '${loc['cost']} JD' : null,
              'emoji': loc['emoji'],
            };
          }).toList(),
        };
      }),
    };

    Navigator.pushNamed(context, '/your-trip', arguments: tripMap);
  }

  @override
  Widget build(BuildContext context) {
    final pills = List.generate(_days, (i) => i);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your AI Plan'),
        elevation: 0,
        backgroundColor: const Color(0xFFF5E8C7),
        foregroundColor: const Color(0xFF5C1E16),
      ),
      backgroundColor: const Color(0xFFF8EDEB),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _fetch)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Text(
                        'Help us plan your perfect trip — just a few quick questions!',
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFF5C1E16)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Day chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        children: pills.map((i) {
                          final sel = i == _selectedDay;
                          return ChoiceChip(
                            label: Text('Day ${i + 1}'),
                            selected: sel,
                            onSelected: (_) => setState(() => _selectedDay = i),
                            selectedColor: const Color(0xFFC03A2B),
                            labelStyle: TextStyle(
                              color:
                                  sel ? Colors.white : const Color(0xFF5C1E16),
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: const Color(0xFFDEC9B2),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Suggested plan for the day',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5C1E16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(child: _buildDayList(_selectedDay)),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side:
                                    const BorderSide(color: Color(0xFFC03A2B)),
                                foregroundColor: const Color(0xFFC03A2B),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('BACK',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveAndContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC03A2B),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('SAVE & CONTINUE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDayList(int dayIndex) {
    final items = (dayIndex < _rec.length)
        ? _rec[dayIndex]
        : const <Map<String, dynamic>>[];
    if (items.isEmpty) {
      return const Center(
        child: Text('No activities for this day. Try different preferences.',
            style: TextStyle(color: Color(0xFF5C1E16))),
      );
    }

    
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final loc = items[index];

        final name = (loc['name'] ?? 'Activity').toString();
        final place = (loc['city'] ?? '').toString().isNotEmpty
            ? loc['city'].toString()
            : (loc['lat'] != null && loc['lon'] != null)
                ? '${(loc['lat'] as num).toStringAsFixed(3)}, ${(loc['lon'] as num).toStringAsFixed(3)}'
                : 'Jordan';
        final cost = (loc['cost'] is num) ? '${loc['cost']} JD' : '—';
        final tags =
            (loc['cat'] is List) ? List<String>.from(loc['cat']) : <String>[];

        return _SuggestionCard(
          title: name,
          location: place,
          cost: cost,
          tags: tags,
          onReplace: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Replace tapped')));
          },
          onRemove: () {
            setState(() {
              _rec[dayIndex].removeAt(index);
            });
          },
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String location;
  final String cost;
  final List<String> tags;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  const _SuggestionCard({
    required this.title,
    required this.location,
    required this.cost,
    required this.tags,
    required this.onReplace,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8DE),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5C1E16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location • Cost
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(children: [
                const Icon(Icons.place, color: Color(0xFF5C1E16), size: 18),
                const SizedBox(width: 4),
                Text(location,
                    style: const TextStyle(color: Color(0xFF5C1E16))),
              ]),
              Row(children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: Color(0xFF5C1E16), size: 18),
                const SizedBox(width: 4),
                Text(cost, style: const TextStyle(color: Color(0xFF5C1E16))),
              ]),
            ],
          ),

          const SizedBox(height: 10),

          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFF2B0D0D),
                          borderRadius: BorderRadius.circular(20)),
                      child:
                          Text(t, style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
          ),

          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              TextButton.icon(
                onPressed: onReplace,
                icon: const Icon(Icons.swap_horiz, color: Color(0xFFC03A2B)),
                label: const Text('Replace',
                    style: TextStyle(color: Color(0xFFC03A2B))),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onRemove,
                icon:
                    const Icon(Icons.delete_outline, color: Color(0xFFC03A2B)),
                label: const Text('Remove',
                    style: TextStyle(color: Color(0xFFC03A2B))),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.info_outline, color: Color(0xFFC03A2B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(error, style: const TextStyle(color: Colors.red)),
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}
