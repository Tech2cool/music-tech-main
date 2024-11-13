import 'package:flutter/material.dart';
import 'package:music_tech/core/models/search_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerPage extends StatefulWidget {
  final SearchModel music;

  const MusicPlayerPage({super.key, required this.music});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final YoutubeExplode _yt = YoutubeExplode();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool isLoading = false;
  String _title = '';
  String _thumbnailUrl = '';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLooping = false;

  @override
  void initState() {
    super.initState();
    _playAudioFromYouTube(widget.music.videoId ?? "");

    // Listen for changes in playback position
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    // Listen for changes in audio duration
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });
  }

  Future<void> _playAudioFromYouTube(String videoId) async {
    try {
      setState(() {
        _isPlaying = true;
        isLoading = true;
      });
      // var video = await _yt.videos.get(videoId);
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      // Set audio URL and play
      await _audioPlayer.setUrl(audioStreamInfo.url.toString());
      _audioPlayer.play();

      setState(() {
        _title = widget.music.name;
        isLoading = false;
        _thumbnailUrl = (widget.music.thumbnails.length > 1
                ? widget.music.thumbnails[1]?.url
                : widget.music.thumbnails[0]?.url) ??
            '';
      });
    } catch (e) {
      setState(() {
        _isPlaying = false;
        isLoading = false;

        print("Error: $e");
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _yt.close();
    super.dispose();
  }

  // Toggle play/pause
  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  // Toggle loop/repeat
  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
    _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
  }

  // Seek to a position in the audio
  void _seekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_thumbnailUrl.isNotEmpty)
                  Image.network(
                    _thumbnailUrl,
                    height: 200,
                  ),
                const SizedBox(height: 16),
                Text(
                  widget.music.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Artist: ${widget.music.artist?.name ?? "NA"}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Album: ${widget.music.album?.name ?? "NA"}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Slider(
                  value: _position.inSeconds.toDouble(),
                  min: 0.0,
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    _seekTo(Duration(seconds: value.toInt()));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.loop,
                        color: _isLooping ? Colors.orange : Colors.grey,
                      ),
                      onPressed: _toggleLoop,
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 64,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: () {
                        _audioPlayer.stop();
                        setState(() {
                          _isPlaying = false;
                          _position = Duration.zero;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }

  // Format duration to a readable string
  String _formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0");
  }
}
