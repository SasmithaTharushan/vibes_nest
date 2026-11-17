import 'package:material_ui/material_ui.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Plays one YouTube video. Owns its controller and closes it only after the
/// widget is gone (so a closing dialog never uses a closed player).
class YouTubeVideo extends StatefulWidget {
  const YouTubeVideo({super.key, required this.videoId});

  final String videoId;

  @override
  State<YouTubeVideo> createState() => _YouTubeVideoState();
}

class _YouTubeVideoState extends State<YouTubeVideo> {
  late final YoutubePlayerController _controller =
      YoutubePlayerController.fromVideoId(
    videoId: widget.videoId,
    autoPlay: true,
    // Keep "related videos" to the same channel: calmer for a wellbeing app.
    params: const YoutubePlayerParams(strictRelatedVideos: true),
  );

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      YoutubePlayer(controller: _controller);
}

/// Shows a video in a dialog with a close button.
Future<void> showVideoDialog(BuildContext context, String videoId) =>
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            YouTubeVideo(videoId: videoId),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
