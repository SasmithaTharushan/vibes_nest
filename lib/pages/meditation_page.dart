import 'package:material_ui/material_ui.dart';
import '../widgets/youtube_video.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {

  // 🔹 List of meditation videos with unique video IDs
  final List<Map<String, dynamic>> videoData = [
    {
      'title': 'Welcome',
      'subtitle': 'Find your inner peace',
      'color': Colors.tealAccent.shade700,
      'icon': Icons.spa,
      'videoId': 'ez3GgRqhNvA',
      'length': '10 min guided',
    },
    {
      'title': 'Harmony',
      'subtitle': 'Balance mind and body',
      'color': Colors.indigoAccent,
      'icon': Icons.self_improvement,
      'videoId': 'x6UITRjhijI',
      'length': 'Healing sounds',
    },
    {
      'title': 'Serenity',
      'subtitle': 'Find peace in nature',
      'color': Colors.greenAccent.shade700,
      'icon': Icons.park,
      'videoId': 'YCLnDcEP-1I',
      'length': 'Nature sounds',
    },
    {
      'title': 'Stillness',
      'subtitle': 'Quiet your thoughts',
      'color': Colors.blueAccent,
      'icon': Icons.menu_book,
      'videoId': 'rG_mpEJcOtg',
      'length': 'Guided journey',
    },
  ];

  /// 🔹 Opens a YouTube video in a dialog box
  void _playVideo(String videoId) => showVideoDialog(context, videoId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meditation Sessions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Column(
              children: videoData.map((video) {
                return _buildMeditationCard(
                  title: video['title'],
                  subtitle: video['subtitle'],
                  duration: video['length'],
                  color: video['color'],
                  icon: video['icon'],
                  videoId: video['videoId'],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Builds a meditation card UI for each video
  Widget _buildMeditationCard({
    required String title,
    required String subtitle,
    required String duration,
    required Color color,
    required IconData icon,
    required String videoId,
  }) {
    return GestureDetector(
      onTap: () => _playVideo(videoId),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.headphones, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(duration,
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
