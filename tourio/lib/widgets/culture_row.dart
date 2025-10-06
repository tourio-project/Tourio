import 'package:flutter/material.dart';

class CultureRow extends StatelessWidget {
  const CultureRow({super.key});

  @override
  Widget build(BuildContext context) {
    const beige = Color(0xFFF3E8DE);

    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: const [
          _CultureCard(title: 'Etiquette', routeName: '/etiquette'),
          SizedBox(width: 16),
          _CultureCard(title: 'Culture', routeName: '/culture'),
          SizedBox(width: 16),
          _CultureCard(title: 'Phrases', routeName: '/phrases'),
        ],
      ),
    );
  }
}

class _CultureCard extends StatelessWidget {
  const _CultureCard({required this.title, required this.routeName});

  final String title;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    const beige = Color(0xFFF3E8DE);

    return SizedBox(
      width: 220,
      child: Material(
        color: beige,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pushNamed(context, routeName),
          child: Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomCenter,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
