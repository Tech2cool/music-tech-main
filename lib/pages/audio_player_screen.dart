import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_tech/core/provider/audio_service_provider.dart';
import 'package:provider/provider.dart';

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioServiceProvider = Provider.of<AudioServiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Audio Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<bool>(
              stream: audioServiceProvider.isPlaying,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 64,
                  ),
                  onPressed: audioServiceProvider.playPause,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop, size: 64),
              onPressed: audioServiceProvider.stop,
            ),
            const SizedBox(height: 20),
            StreamBuilder<MediaItem?>(
              stream: audioServiceProvider.audioHandler.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                return Text(
                  mediaItem?.title ?? 'No track selected',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder<Duration>(
              stream: audioServiceProvider.audioHandler.playbackState
                  .map((state) => state.position)
                  .distinct(),
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return Text(
                  'Position: ${position.inSeconds} seconds',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          audioServiceProvider.loadAndPlay(
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          );
        },
        child: const Icon(Icons.music_note),
      ),
    );
  }
}
