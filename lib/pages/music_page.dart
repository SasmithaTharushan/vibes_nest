import 'package:material_ui/material_ui.dart';
import '../widgets/youtube_video.dart';

/// A track shown on the Music page. Titles are stored with the video ID so the
/// page works offline and needs no YouTube Data API key.
class Song {
  final String videoId;
  final String title;
  final String artist;
  const Song(this.videoId, this.title, this.artist);
}

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  String selectedCategory = "Energizing";

  static const Map<String, List<Song>> categorizedSongs = {
    "Energizing": [
      Song('CevxZvSJLk8', 'Roar', 'Katy Perry'),
      Song('PsO6ZnUZI0g', 'Stronger', 'Kanye West'),
      Song('ru0K8uYEZWw', "Can't Stop the Feeling!", 'Justin Timberlake'),
    ],
    "Positive": [
      Song('ZbZSe6N_BXs', 'Happy', 'Pharrell Williams'),
      Song('jZhQOvvV45w', 'Good Life', 'OneRepublic'),
      Song('OPf0YbXqDm0', 'Uptown Funk ft. Bruno Mars', 'Mark Ronson'),
    ],
    "Calm": [
      Song('UfcAVejslrU', 'Weightless', 'Marconi Union'),
      Song('1ZYbU82GVz4', 'Flying: Relaxing Sleep Music', 'Peder B. Helland'),
      Song('2OEL4P1Rz04', 'The Hidden Valley: Ambient Music',
          'Soothing Relaxation'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final songs = categorizedSongs[selectedCategory] ?? const <Song>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music & Motivation',
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
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: songs.length,
                itemBuilder: (context, index) => _buildSongCard(songs[index]),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildSongCard(Song song) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      shadowColor: Colors.black26,
      color: Colors.white.withValues(alpha: 0.9),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            'https://img.youtube.com/vi/${song.videoId}/0.jpg',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          song.title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(
          song.artist,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        trailing: Icon(Icons.play_arrow_rounded,
            color: Colors.purpleAccent, size: 30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  YouTubePlayerScreen(videoId: song.videoId),
            ),
          );
        },
      ),
    );
  }
}

class YouTubePlayerScreen extends StatelessWidget {
  const YouTubePlayerScreen({super.key, required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade300,
      ),
      body: Center(child: YouTubeVideo(videoId: videoId)),
    );
  }
}
