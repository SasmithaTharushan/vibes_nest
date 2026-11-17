import 'package:material_ui/material_ui.dart';

import '../models/wellness_models.dart';
import '../services/app_services.dart';
import 'breath_control_page.dart';
import 'let_it_go_page.dart';
import 'progress_tracker.dart';
import 'sleep_traking_page.dart';
import 'stay_calm_page.dart';

/// "My Garden": plants grow from real self-care activities.
class GardenPage extends StatelessWidget {
  const GardenPage({super.key});

  static const plantImages = [
    'assets/images/plant-one.png',
    'assets/images/plant-two.png',
    'assets/images/plant-three.png',
    'assets/images/plant-four.png',
    'assets/images/plant-five.png',
    'assets/images/plant-six.png',
    'assets/images/plant-seven.png',
    'assets/images/plant-eight.png',
  ];

  static const _green = Color(0xff296e48);

  Widget _pageFor(Activity a) {
    switch (a) {
      case Activity.mood:
        return const ProgressTrackerPage();
      case Activity.journal:
        return const LetItGoPage();
      case Activity.sleep:
        return const SleepTrackingPage();
      case Activity.breathing:
        return const BreathControlPage();
      case Activity.grounding:
        return const StayCalmPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppServices.repo(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Garden')),
      body: StreamBuilder<GardenStats>(
        stream: repo.watchGarden(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final g = snapshot.data!;
          final streak = g.currentStreak(DateTime.now());
          final growing = plantImages[g.plants % plantImages.length];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _Stat(label: 'Points', value: '${g.points}', icon: Icons.eco),
                  _Stat(
                      label: 'Day streak',
                      value: '$streak',
                      icon: Icons.local_fire_department),
                  _Stat(
                      label: 'Plants',
                      value: '${g.plants}',
                      icon: Icons.yard),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: const Color(0xffeaf4ee),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        g.points == 0
                            ? 'Plant your first seed'
                            : 'Growing your next plant',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: Center(
                          child: g.growth == 0
                              ? const Icon(Icons.grass, size: 56, color: _green)
                              : AnimatedScale(
                                  scale: 0.35 + 0.65 * g.growth / 10,
                                  duration: const Duration(milliseconds: 400),
                                  child: Image.asset(growing, height: 140),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: g.growth / GardenStats.pointsPerPlant,
                        minHeight: 8,
                        color: _green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 6),
                      Text(
                          '${GardenStats.pointsPerPlant - g.growth} points until it blooms'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (g.plants > 0) ...[
                const Text('Your garden',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    for (var i = 0; i < g.plants; i++)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffeaf4ee),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                            plantImages[i % plantImages.length]),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              const Text('How to grow your garden',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                  'Every bit of self-care counts. Do something each day to keep '
                  'your streak. Best streak: ${g.bestStreak} days.',
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              for (final a in Activity.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xffeaf4ee),
                    child: Text('+${a.points}',
                        style: const TextStyle(
                            color: _green, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(a.label),
                  subtitle: Text('Done ${g.counts[a.name] ?? 0} times'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => _pageFor(a))),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xff296e48)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
