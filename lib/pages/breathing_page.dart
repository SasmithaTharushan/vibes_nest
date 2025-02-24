import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class BreathingPage extends StatefulWidget {
  @override
  _BreathingPageState createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  final List<Map<String, dynamic>> videoData = [
    {
      'title': 'Deep Breathing',
      'subtitle': 'Enhance lung capacity',
      'color': Colors.blueAccent,
      'icon': Icons.air,
      'videoId': 'kpSkoXRrZnE'
    },
    {
      'title': 'Box Breathing',
      'subtitle': 'Calm and focus your mind',
      'color': Colors.teal,
      'icon': Icons.self_improvement,
      'videoId': '1YjZA95tEDo'
    },
    {
      'title': 'Alternate Nostril',
      'subtitle': 'Balance and refresh',
      'color': Colors.greenAccent.shade700,
      'icon': Icons.waves,
      'videoId': '0BNejY1e9ik'
    },
  ];

  late YoutubePlayerController _controller;

  void _playVideo(String videoId) {
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: YoutubePlayer(controller: _controller),
      ),
    ).then((_) => _controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Techniques'),
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
              'Breathing Exercises',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Column(
              children: videoData.map((video) {
                return _buildBreathingCard(
                  title: video['title'],
                  subtitle: video['subtitle'],
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

  Widget _buildBreathingCard({
    required String title,
    required String subtitle,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
