import 'package:flutter/material.dart';

class GroupSizePage extends StatefulWidget {
  const GroupSizePage({super.key});

  @override
  State<GroupSizePage> createState() => _GroupSizePageState();
}

class _GroupSizePageState extends State<GroupSizePage> {

  static const cream       = Color(0xFFF3E8DE);
  static const maroon      = Color(0xFF5C1E16);
  static const accent      = Color(0xFFC03A2B);
  static const fieldBg     = Color(0xFF2B0D0D);
  static const fieldBorder = Color(0xFF61201B);

   // 'Solo' or 'Group'
  String _mode = 'Solo'; 
  final List<TextEditingController> _friendCtrls = [TextEditingController()];

  @override
  void dispose() {
    for (final c in _friendCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addField() => setState(() => _friendCtrls.add(TextEditingController()));
  void _removeField(int i) {
    if (_friendCtrls.length == 1) return;
    setState(() {
      _friendCtrls[i].dispose();
      _friendCtrls.removeAt(i);
    });
  }

  void _goNext() {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final friendIds = _mode == 'Group'
        ? _friendCtrls
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList()
        : <String>[];

    final nextArgs = {
      ...args,
      'travelMode': _mode,
      'friendIds': friendIds,
    };

    Navigator.pushNamed(context, '/budget', arguments: nextArgs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Help us plan your perfect trip — just a few quick questions!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: maroon, height: 1.35),
              ),
              const SizedBox(height: 40),

              const Text(
                'Are you exploring solo or in a group ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: maroon,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),

              // Solo / Group segmented control
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(value: 'Solo',  label: Text('Solo')),
                  ButtonSegment<String>(value: 'Group', label: Text('Group')),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  side: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    return BorderSide(
                      color: selected ? accent : fieldBorder,
                      width: selected ? 2 : 1.2,
                    );
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    return selected ? fieldBg.withOpacity(.95) : fieldBg;
                  }),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  overlayColor: WidgetStateProperty.all(accent.withOpacity(.08)),
                ),
              ),

              if (_mode == 'Group') ...[
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Add your friends' IDs:",
                    style: TextStyle(
                      color: maroon,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                for (int i = 0; i < _friendCtrls.length; i++) ...[
                  _FriendIdField(
                    controller: _friendCtrls[i],
                    hint: 'friend_${i + 1}',
                    onRemove:
                        _friendCtrls.length > 1 ? () => _removeField(i) : null,
                  ),
                  const SizedBox(height: 12),
                ],

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addField,
                    icon: const Icon(Icons.add, color: accent),
                    label: const Text('Add another',
                        style: TextStyle(color: accent)),
                  ),
                ),
              ],

              const SizedBox(height: 48),

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

class _FriendIdField extends StatelessWidget {
  const _FriendIdField({
    required this.controller,
    required this.hint,
    this.onRemove,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback? onRemove;

  static const fieldBg = _GroupSizePageState.fieldBg;
  static const fieldBorder = _GroupSizePageState.fieldBorder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: fieldBg,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: fieldBorder, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ),
        if (onRemove != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
            tooltip: 'Remove',
          ),
        ],
      ],
    );
  }
}
