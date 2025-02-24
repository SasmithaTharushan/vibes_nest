import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  String selectedCategory = "Energizing";

  final Map<String, List<String>> categorizedSongs = {
    "Energizing": [
      'dQw4w9WgXcQ',
      'PsO6ZnUZI0g',
      'ru0K8uYEZWw',
    ],
    "Positive": [
      'ZbZSe6N_BXs',
      'jZhQOvvV45w',
      'OPf0YbXqDm0',
    ],
    "Calm": [
      'UfcAVejslrU',
      '1ZYbU82GVz4',
      '2OEL4P1Rz04',
    ],
  };

  Future<Map<String, String>> _fetchVideoDetails(String videoId) async {
    final String apiKey =
        'AIzaSyDAs5xGEyFiIgHInhW5qRj0n4jnBoI4PO8'; // Replace with your YouTube API key
    final url =
        'https://www.googleapis.com/youtube/v3/videos?id=$videoId&part=snippet,contentDetails&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['items'].isEmpty) {
        return {
          'videoId': videoId,
          'title': 'Unknown Title',
          'artist': 'Unknown Artist',
          'duration': 'Unknown Duration',
        };
      }

      final videoData = data['items'][0]['snippet'];
      final duration = data['items'][0]['contentDetails']['duration'];

      final title = videoData['title'];
      final artistName = videoData['channelTitle'];

      return {
        'videoId': videoId, // Fix: Add videoId to prevent null issue
        'title': title,
        'artist': artistName,
        'duration': duration,
      };
    } else {
      throw Exception('Failed to load video details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music & Motivation',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade400,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildCategorySelector(),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _getSongDetails(selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No songs available.'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var song = snapshot.data![index];
                      return _buildSongCard(song);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, String>>> _getSongDetails(String category) async {
    List<Map<String, String>> songs = [];

    if (categorizedSongs.containsKey(category)) {
      for (var videoId in categorizedSongs[category]!) {
        try {
          final details = await _fetchVideoDetails(videoId);
          songs.add(details);
        } catch (e) {
          print("Error fetching details for video $videoId: $e");
        }
      }
    }

    return songs;
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: categorizedSongs.keys.map((category) {
          return ChoiceChip(
            label:
                Text(category, style: TextStyle(fontWeight: FontWeight.bold)),
            selected: selectedCategory == category,
            selectedColor: Colors.purpleAccent.shade100,
            backgroundColor: Colors.white70,
            elevation: 2,
            onSelected: (bool selected) {
              if (selected) {
                setState(() {
                  selectedCategory = category;
                });
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSongCard(Map<String, String> song) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      shadowColor: Colors.black26,
      color: Colors.white.withOpacity(0.9),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            'https://img.youtube.com/vi/${song['videoId']}/0.jpg',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          song['title']!,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(
          song['artist']!,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        trailing: Icon(Icons.play_arrow_rounded,
            color: Colors.purpleAccent, size: 30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  YouTubePlayerScreen(videoId: song['videoId']!),
            ),
          );
        },
      ),
    );
  }
}

class YouTubePlayerScreen extends StatefulWidget {
  final String videoId;
  YouTubePlayerScreen({required this.videoId});

  @override
  _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Now Playing", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade300,
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.purpleAccent,
        ),
      ),
    );
  }
}
