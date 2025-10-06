import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/navigation_utils.dart';

const _cream = Color(0xFFF3E8DE);
const _maroon = Color(0xFF5C1E16);
const _accent = Color(0xFFC03A2B);
const _chipBg = Color(0xFF2B0D0D);

// --------- Models ---------
class TripPlan {
  TripPlan({required this.members, required this.days});
  final List<Member> members;
  final List<PlanDay> days;

  factory TripPlan.fromMap(Map<String, dynamic> m) => TripPlan(
        members: (m['members'] as List? ?? [])
            .map((e) => Member.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        days: (m['days'] as List? ?? [])
            .map((e) => PlanDay.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class Member {
  Member({required this.name, this.photo});
  final String name;
  final String? photo;
  factory Member.fromMap(Map<String, dynamic> m) =>
      Member(name: (m['name'] ?? 'Friend').toString(), photo: m['photo']);
}

class PlanDay {
  PlanDay({required this.title, required this.activities});
  final String title;
  final List<Activity> activities;
  factory PlanDay.fromMap(Map<String, dynamic> m) => PlanDay(
        title: (m['title'] ?? 'Day').toString(),
        activities: (m['activities'] as List? ?? [])
            .map((e) => Activity.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class Activity {
  Activity({
    required this.time,
    required this.duration,
    required this.title,
    required this.location,
    this.transport,
    this.cost,
    this.emoji,
  });

  final String time, duration, title, location;
  final String? transport, cost, emoji;

  factory Activity.fromMap(Map<String, dynamic> m) => Activity(
        time: (m['time'] ?? '').toString(),
        duration: (m['duration'] ?? '').toString(),
        title: (m['title'] ?? '').toString(),
        location: (m['location'] ?? '').toString(),
        transport: (m['transport'] as String?),
        cost: (m['cost'] as String?),
        emoji: (m['emoji'] as String?),
      );
}

// --------- Page ---------
class YourTripPage extends StatefulWidget {
  const YourTripPage({super.key});
  @override
  State<YourTripPage> createState() => _YourTripPageState();
}

class _YourTripPageState extends State<YourTripPage>
    with TickerProviderStateMixin {
  late TripPlan _plan;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _plan = _mockPlan();
    _tab = TabController(length: _plan.days.length, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      final incoming = TripPlan.fromMap(args);
      if (incoming.days.isNotEmpty) {
        final newLen = incoming.days.length;

       
        if (newLen != _tab.length) {
          _tab.dispose();
          _tab = TabController(length: newLen, vsync: this);
        }

        _plan = incoming;

        
        if (_tab.index >= _plan.days.length) {
          _tab.index = _plan.days.length - 1;
        }
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final safeIndex = math.min(_tab.index, _plan.days.length - 1);

    return Scaffold(
      backgroundColor: _cream,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerScrolled) => [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 220,
            collapsedHeight: 80,
            pinned: true,
            elevation: 0,
            centerTitle: false,
            title: innerScrolled
                ? const Text('Your Trip',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ))
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/petra_image.jpg',
                      fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Container(
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
            ),
          ),
        ],
        body: Container(
          color: Colors.white,
          child: _content(context, safeIndex),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, 1),
    );
  }

  Widget _content(BuildContext context, int safeIndex) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 10),

        const Text(
          'Your Trip',
          style: TextStyle(
            fontFamily: 'ArefRuqaaInk',
            fontSize: 32,
            color: _maroon,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),

        _MembersRow(members: _plan.members),
        const SizedBox(height: 12),

        TextField(
          decoration: InputDecoration(
            hintText: 'Search by place, keyword, activity, etc.',
            prefixIcon: const Icon(Icons.search),
            fillColor: _cream,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8D8CE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 1.6),
            ),
          ),
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            const Expanded(
              child: Text(
                'Proposed Plan',
                style: TextStyle(
                  fontFamily: 'ArefRuqaaInk',
                  fontSize: 22,
                  color: _maroon,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Regenerate',
              icon: const Icon(Icons.auto_awesome, color: _accent),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Regenerating…')),
                );
              },
            ),
            IconButton(
              tooltip: 'Edit trip',
              icon: const Icon(Icons.edit_outlined, color: _accent),
              onPressed: () {},
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _cream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tab,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: _maroon,
            indicator: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(10),
            ),
            labelPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            tabs: _plan.days.map((d) => Tab(text: d.title)).toList(),
          ),
        ),
        const SizedBox(height: 12),

    
        ..._plan.days[safeIndex].activities.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActivityCard(activity: a),
          ),
        ),
      ],
    );
  }


  TripPlan _mockPlan() {
    final members = [
      Member(name: 'You'),
      Member(name: 'Sara'),
      Member(name: 'Omar')
    ];
    final day1 = PlanDay(title: 'Day 1', activities: [
      Activity(
        time: '6:00 pm',
        duration: '3 hr',
        title: 'Wadi Rum Sunset Jeep Tour',
        location: 'Wadi Rum',
        transport: 'Bus or car',
        cost: '25 JD cash / VISA',
        emoji: '🏜️',
      ),
    ]);
    final day2 = PlanDay(title: 'Day 2', activities: [
      Activity(
        time: '10:00 am',
        duration: '2 hr',
        title: 'Petra Treasury Walk',
        location: 'Petra',
        transport: 'On foot',
        cost: 'Entry ticket',
        emoji: '🏛️',
      ),
    ]);
    final day3 = PlanDay(title: 'Day 3', activities: [
      Activity(
        time: '1:00 pm',
        duration: '4 hr',
        title: 'Dead Sea Float & Lunch',
        location: 'Dead Sea',
        transport: 'Shuttle',
        cost: '45 JD',
        emoji: '🌊',
      ),
    ]);
    return TripPlan(members: members, days: [day1, day2, day3]);
  }
}

// --------- Widgets ---------
class _MembersRow extends StatelessWidget {
  const _MembersRow({required this.members});
  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final m in members.take(5)) ...[
            _Avatar(name: m.name, photo: m.photo),
            const SizedBox(width: 12),
          ],
          const Spacer(),
          const Row(
            children: [
              Icon(Icons.group_add_outlined, size: 18, color: _maroon),
              SizedBox(width: 6),
              Text('Manage', style: TextStyle(color: _maroon)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.photo});
  final String name;
  final String? photo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: _chipBg,
          foregroundColor: Colors.white,
          backgroundImage:
              (photo != null && photo!.isNotEmpty) ? AssetImage(photo!) : null,
          child: (photo == null || photo!.isEmpty)
              ? Text(name.isNotEmpty ? name[0] : '?')
              : null,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _maroon, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cream,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cream,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE7D6CC)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.schedule, color: _accent, size: 18),
                  const SizedBox(height: 6),
                  Text(activity.time,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _maroon, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(activity.duration,
                        style: const TextStyle(color: _accent, fontSize: 11.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title,
                      style: const TextStyle(
                          color: _maroon,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 16, color: _accent),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(activity.location,
                            style:
                                const TextStyle(color: _maroon, fontSize: 13)),
                      ),
                    ],
                  ),
                  if (activity.transport != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.directions_bus_outlined,
                            size: 16, color: _accent),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(activity.transport!,
                              style: const TextStyle(
                                  color: _maroon, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                  if (activity.cost != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined,
                            size: 16, color: _accent),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(activity.cost!,
                              style: const TextStyle(
                                  color: _maroon, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
