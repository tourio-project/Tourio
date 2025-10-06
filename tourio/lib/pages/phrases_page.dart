import 'package:flutter/material.dart';

const _maroon = Color(0xFF5C1E16);
const _cardBg = Color(0xFF5C1E16);

class PhrasesPage extends StatelessWidget {
  const PhrasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFDF7F2),
      body: SafeArea(
        child: Column(
          children: [
            _Header(current: _TabKind.phrases),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    _PhraseSection(
                      title: 'Greetings & Basics',
                      items: [
                        ('Hello', 'مرحبا'),
                        ('Peace be upon you', 'السلام عليكم'),
                        ('Thank you', 'شكراً'),
                        ('You’re welcome', 'عفواً'),
                        ('Please', 'من فضلك'),
                        ('Excuse me / Sorry', 'عفواً / لو سمحت'),
                        ('Good morning', 'صباح الخير'),
                        ('Good evening', 'مساء الخير'),
                        ('Goodbye', 'مع السلامة'),
                        ('Welcome', 'أهلاً وسهلاً'),
                      ],
                    ),
                    _PhraseSection(
                      title: 'Polite interactions',
                      items: [
                        ('How are you?', 'كيف حالك؟'),
                        ('Good', 'منيح'),
                        ('No problem', 'ما في مشكلة'),
                        ('Yes / No', 'نعم / لا'),
                        ('What’s your name?', 'شو اسمك؟'),
                        ('My name is…', 'اسمي…'),
                        ('Nice to meet you', 'تشرفنا'),
                      ],
                    ),
                    _PhraseSection(
                      title: 'Practical phrases',
                      items: [
                        ('How much is this?', 'بكم هذا؟'),
                        ('Where is the bathroom?', 'وين الحمام؟'),
                        ('I don’t understand', 'ما فهمت'),
                        ('Do you speak English?', 'بتحكي إنجليزي؟'),
                        ('I want this', 'بدي هذا'),
                        ('Too expensive!', 'غالي كتير!'),
                        ('Can you lower the price?', 'بترخص شوي؟'),
                        ('Where is…?', 'وين…؟'),
                        ('Left / Right / Straight', 'يمين / شمال / دغري'),
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

/// ---- shared header/tabs ----

enum _TabKind { etiquette, culture, phrases }

class _Header extends StatelessWidget {
  const _Header({required this.current});
  final _TabKind current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar: back button + logo
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

        // Tabs row
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

/// ---- phrases sections ----

class _PhraseSection extends StatelessWidget {
  const _PhraseSection({required this.title, required this.items});
  final String title;
  final List<(String, String)> items; 

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
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _maroon,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((pair) => _PhraseTile(english: pair.$1, arabic: pair.$2)),
        ],
      ),
    );
  }
}

class _PhraseTile extends StatelessWidget {
  const _PhraseTile({required this.english, required this.arabic});
  final String english;
  final String arabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Text(
            english,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          // Arabic
          Text(
            arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _maroon,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
