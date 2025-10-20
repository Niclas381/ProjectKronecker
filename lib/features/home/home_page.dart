import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const tiles = [
      _HomeTile(
        label: 'To-Do Tracker',
        icon: Icons.check_circle_outline,
        route: '/todo',
      ),
      _HomeTile(
        label: 'Kalender',
        icon: Icons.calendar_month,
        route: '/calendar',
      ),
      _HomeTile(
        label: 'Ausgaben',
        icon: Icons.account_balance_wallet_outlined,
        route: '/expenses',
      ),
    ];

    return Scaffold( // <- Material-Vorfahre, keine AppBar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.05,
            ),
            itemCount: tiles.length,
            itemBuilder: (_, i) => tiles[i],
          ),
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  const _HomeTile({required this.label, required this.icon, required this.route});

  @override
  Widget build(BuildContext context) {
    return Card( // Card (Material) ist jetzt über InkWell
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(route),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(icon, size: 36),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
