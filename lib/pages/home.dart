import 'package:material_ui/material_ui.dart';
import 'meditation_page.dart';
import 'library_page.dart';
import 'music_page.dart';
import 'garden_page.dart';
import 'community.dart';
import 'find_help_page.dart';
import 'let_it_go_page.dart';
import 'chat_screen.dart';
import 'sleep_traking_page.dart';
import 'breathing_page.dart';
import 'progress_tracker.dart';
import 'profile_page.dart';
import 'breath_control_page.dart';
import 'stay_calm_page.dart';
import 'crisis_help_page.dart';
import '../services/app_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Recommended';
  int _selectedIndex = 0;

  String get _name => AppServices.auth(context).displayName;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  final Map<String, List<Map<String, dynamic>>> _categoryContent = {
    'Recommended': [
      {
        'title': 'My Garden',
        'subtitle': 'Grow plants with every bit of self-care',
        'color': Color(0xff296e48),
        'icon': Icons.yard,
      },
      {
        'title': 'Access our library',
        'subtitle': 'From conflict to harmony',
        'color': Colors.greenAccent,
        'icon': Icons.menu_book,
      },
      {
        'title': 'Want to talk to someone?',
        'subtitle': 'Discover the art of stillness',
        'color': Colors.orangeAccent,
        'icon': Icons.support_agent,
      },
      {
        'title': 'Let It Go',
        'subtitle': 'Release your worries and relax',
        'color': Colors.blueGrey,
        'icon': Icons.cloud,
      },
      {
        'title': 'Find professional help',
        'subtitle': 'Verified counselling services in Sri Lanka',
        'color': Colors.lightBlueAccent,
        'icon': Icons.health_and_safety,
      },
    ],
    'Breathe': [
      {
        'title': 'Deep Breathing',
        'subtitle': 'Improve your focus',
        'color': Colors.blueAccent,
        'icon': Icons.air,
      },
      {
        'title': 'Breath Control',
        'subtitle': 'Calm your mind',
        'color': Colors.cyan,
        'icon': Icons.self_improvement,
      },
    ],
    'Calm': [
      {
        'title': 'Stay Calm',
        'subtitle': 'Find inner peace',
        'color': Colors.purpleAccent,
        'icon': Icons.nightlight_round,
      },
    ],
    'Music': [
      {
        'title': 'Relaxing Sounds',
        'subtitle': 'Feel the tranquility',
        'color': Colors.deepOrange,
        'icon': Icons.music_note,
      },
    ],
    'Community': [
      {
        'title': 'Join Discussions',
        'subtitle': 'Engage with others',
        'color': Colors.teal,
        'icon': Icons.forum,
      },
    ],
  };

  void _onCategoryTap(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MeditationPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SleepTrackingPage()),
      );
    } else if (index == 2) {
      // Navigate to Progress Tracker Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProgressTrackerPage()),
      );
    }
  }

  void _navigateTo(BuildContext context, String title) {
    if (title == 'Profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else if (title == 'Access our library') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LibraryPage()),
      );
    } else if (title == 'Relaxing Sounds') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MusicPage()),
      );
    } else if (title == 'Want to talk to someone?') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen()), // Updated to ChatScreen
      );
    } else if (title == 'Relaxing Sounds') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MusicPage()),
      );
    } else if (title == 'Deep Breathing') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BreathingPage()),
      );
    } else if (title == 'Find professional help') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FindHelpPage()),
      );
    } else if (title == 'Join Discussions') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CommunityPage()),
      );
    } else if (title == 'Let It Go') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LetItGoPage()),
      );
    } else if (title == 'Breath Control') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BreathControlPage()),
      );
    } else if (title == 'My Garden') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GardenPage()),
      );
    } else if (title == 'Stay Calm') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StayCalmPage()),
      );
    } else {
      assert(false, 'No page registered for "$title"');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => _navigateTo(context, 'Profile'),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.person_3_rounded, color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Get help now',
            icon: const Icon(Icons.sos, color: Colors.red),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CrisisHelpPage()),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GardenPage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.park_outlined),
            ),
          ),
        ],
        title: const Text(
          'Vibes Nest',
          style: TextStyle(
            fontFamily: 'Serif',
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_greeting, $_name',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Top meditation program for you',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            _buildCategoryChips(),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey<String>(_selectedCategory),
                children: _categoryContent[_selectedCategory]!
                    .map((data) => _buildCard(
                          title: data['title'],
                          subtitle: data['subtitle'],
                          color: data['color'],
                          image: data['icon'],
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.spa),
            label: 'Meditation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nightlight_round),
            label: 'Sleep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categoryContent.keys.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (bool selected) {
                if (selected) {
                  _onCategoryTap(category);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData image,
  }) {
    return GestureDetector(
      onTap: () => _navigateTo(context, title),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Icon(image, size: 60, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

