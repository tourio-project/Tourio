import 'package:flutter/material.dart';

const _maroon = Color(0xFF5C1E16);
const _beige  = Color(0xFFF3E8DE);
const _cardBg = Color(0xFF5C1E16); 

class EtiquettePage extends StatelessWidget {
  const EtiquettePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFDF7F2),
      body: SafeArea(
        child: Column(
          children: [
            _Header(current: _TabKind.etiquette),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BulletSection(
                      title: 'Greetings',
                      bullets: [
                        'Shake hands (lightly), use the right hand.',
                        'Stand up when it comes to greeting others.',
                        'Men: handshake (light grip). If close, cheek kisses (right-left-right).',
                        'Men & women: don’t assume handshakes—wait to see if the woman offers her hand.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Hospitality',
                      bullets: [
                        'Always accept coffee/tea when offered, even just a sip. Refusing can seem rude.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Dress code',
                      bullets: [
                        'Dress modestly, especially in rural areas or religious sites (shoulders & knees covered).',
                      ],
                    ),
                    _BulletSection(
                      title: 'Dining etiquette',
                      bullets: [
                        'Use the right hand for eating.',
                        'If eating communal food, eat from the section in front of you.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Social norms',
                      bullets: [
                        'Avoid hugging/kissing in public (except same-gender greetings).',
                        'Remove shoes before entering prayer areas.',
                        'Don’t walk in front of someone praying.',
                        'Carry loose change.',
                        'During Ramadan, avoid publicly eating/drinking during fasting hours.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Photography',
                      bullets: [
                        'Always ask before taking photos of people, especially women.',
                      ],
                    ),
                    _BulletSection(
                      title: 'Tipping',
                      bullets: [
                        'Common in restaurants (5–10%), but never mandatory.',
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
            // Back
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: _maroon),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (r) => false,
                    );
                  }
                },
              ),
            ),
            // Logo image
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
        // Tabs
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
