import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  late YoutubePlayerController _controller;
  final String apiKey =
      'AIzaSyDAs5xGEyFiIgHInhW5qRj0n4jnBoI4PO8'; // 🔹 Replace with your actual API key

  // 🔹 List of meditation videos with unique video IDs
  final List<Map<String, dynamic>> videoData = [
    {
      'title': 'Welcome',
      'subtitle': 'Find your inner peace',
      'color': Colors.tealAccent.shade700,
      'icon': Icons.spa,
      'videoId': 'ez3GgRqhNvA' // Example video ID (replace with real ones)
    },
    {
      'title': 'Harmony',
      'subtitle': 'Balance mind and body',
      'color': Colors.indigoAccent,
      'icon': Icons.self_improvement,
      'videoId': 'x6UITRjhijI' // Example video ID
    },
    {
      'title': 'Serenity',
      'subtitle': 'Find peace in nature',
      'color': Colors.greenAccent.shade700,
      'icon': Icons.park,
      'videoId': 'YCLnDcEP-1I' // Example video ID
    },
    {
      'title': 'Stillness',
      'subtitle': 'Quiet your thoughts',
      'color': Colors.blueAccent,
      'icon': Icons.menu_book,
      'videoId': 'rG_mpEJcOtg' // Example video ID
    },
  ];

  Map<String, String> videoDurations =
      {}; // 🔹 Stores dynamically fetched durations

  @override
  void initState() {
    super.initState();
    _fetchVideoDurations();
  }

  /// 🔹 Fetches actual YouTube video durations
  Future<void> _fetchVideoDurations() async {
    for (var video in videoData) {
      String? duration = await _getVideoDuration(video['videoId']);
      if (duration != null) {
        setState(() {
          videoDurations[video['videoId']] = duration;
        });
      }
    }
  }

  /// 🔹 Calls YouTube API to get video duration
  Future<String?> _getVideoDuration(String videoId) async {
    final String url =
        'https://www.googleapis.com/youtube/v3/videos?id=$videoId&part=contentDetails&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['items'].isNotEmpty) {
        String isoDuration = jsonData['items'][0]['contentDetails']['duration'];
        return _formatDuration(isoDuration);
      }
    }
    return null;
  }

  /// 🔹 Converts YouTube ISO 8601 duration (e.g., PT5M30S) into a readable format
  String _formatDuration(String isoDuration) {
    RegExp regex = RegExp(r'PT(\d+H)?(\d+M)?(\d+S)?');
    Match? match = regex.firstMatch(isoDuration);

    int hours = int.tryParse(match?.group(1)?.replaceAll('H', '') ?? '0') ?? 0;
    int minutes =
        int.tryParse(match?.group(2)?.replaceAll('M', '') ?? '0') ?? 0;
    int seconds =
        int.tryParse(match?.group(3)?.replaceAll('S', '') ?? '0') ?? 0;

    if (hours > 0) {
      return '$hours hr $minutes min';
    } else if (minutes > 0) {
      return '$minutes min $seconds sec';
    } else {
      return '$seconds sec';
    }
  }

  /// 🔹 Opens a YouTube video in a dialog box
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
                  duration: videoDurations[video['videoId']] ?? 'Loading...',
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
                      const Icon(Icons.timer, color: Colors.white, size: 20),
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
