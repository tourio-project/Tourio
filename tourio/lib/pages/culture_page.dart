import 'package:flutter/material.dart';

const _maroon = Color(0xFF5C1E16);
const _cardBg = Color(0xFF5C1E16);

class CulturePage extends StatelessWidget {
  const CulturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFDF7F2),
      body: SafeArea(
        child: Column(
          children: [
            _Header(current: _TabKind.culture),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    _BulletSection(
                      title: 'Hospitality & Family',
                      bullets: [
                        'Jordanians are known for generosity and welcoming guests.',
                        'Strong emphasis on family and community over individualism.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Religion & Fridays',
                      bullets: [
                        'Islam is the main religion; respect prayer times and mosques.',
                        'Friday is the holy day; many businesses close midday for prayer.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Ramadan Tips',
                      bullets: [
                        'No eating/drinking/smoking in public during fasting hours.',
                        'Restaurants may open later in the evening.',
                        'Iftar (breaking fast) is a beautiful communal experience.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Food Culture',
                      bullets: [
                        'Knafeh is a very popular dessert.',
                        'Sharing food from one plate is common.',
                        'Mansaf is the national dish (lamb, rice, jameed yogurt). Eating with the hand is traditional.',
                        'Tap water isn’t recommended to drink—bottled water is cheap and everywhere.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Coffee & Tea',
                      bullets: [
                        'Served as a sign of respect; Arabic coffee often symbolizes trust & peace.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Social Gatherings',
                      bullets: [
                        'In conservative areas, men sit with men, women with women.',
                        'In Amman/urban areas, mixed groups are common—still be respectful and keep some space.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Festivals & Hours',
                      bullets: [
                        'Ramadan and Eid are widely observed; shops/restaurants may close or adjust hours.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Markets (Souks)',
                      bullets: [
                        'Bargaining is part of the culture—done politely and with humor.',
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



enum _TabKind { etiquette, culture, phrases }

class _Header extends StatelessWidget {
  const _Header({required this.current});
  final _TabKind current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: _maroon),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Image.asset(
                'assets/images/star.jpg',
                height: 132,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        Container(
          height: 44,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2E8E1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _TabButton(
                label: 'Etiquette',
                selected: current == _TabKind.etiquette,
                onTap: () => Navigator.pushReplacementNamed(context, '/etiquette'),
              ),
              _TabButton(
                label: 'Culture',
                selected: current == _TabKind.culture,
                onTap: () => Navigator.pushReplacementNamed(context, '/culture'),
              ),
              _TabButton(
                label: 'Phrases',
                selected: current == _TabKind.phrases,
                onTap: () => Navigator.pushReplacementNamed(context, '/phrases'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: _maroon,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.bullets});
  final String title;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _cardBg.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: _maroon,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          ...bullets.map((b) => _BulletLine(text: b)),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(height: 1.4)),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 15, height: 1.45, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
