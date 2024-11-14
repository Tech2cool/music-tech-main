import 'package:flutter/material.dart';
import 'package:music_tech/core/provider/audio_service_provider.dart';
import 'package:music_tech/pages/music_player_page.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioServiceProvider = Provider.of<AudioServiceProvider>(context);
    final mediaItem = audioServiceProvider.audioHandler.mediaItem;
    return mediaItem.valueOrNull == null
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayerPage(
                    music: audioServiceProvider.currentMedia!,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                // color: Colors.red,
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              // margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Thumbnail or default image
                  Row(
                    children: [
                      mediaItem.value?.artUri != null
                          ? Image.network(
                              mediaItem.value!.artUri!.toString(),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.music_note,
                              size: 50,
                              color: Colors.white,
                            ),
                      const SizedBox(width: 10),
                      // Title and artist
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              maxLines: 2,
                              mediaItem.value?.title ?? "Unknown Title",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              maxLines: 1,
                              mediaItem.value?.artist ?? "Unknown Artist",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Play/Pause button
                  StreamBuilder<bool>(
                    stream: audioServiceProvider.isPlaying,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 35,
                        ),
                        onPressed: audioServiceProvider.playPause,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
