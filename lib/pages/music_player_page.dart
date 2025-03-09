import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_tech/core/models/search_model.dart';
import 'package:music_tech/core/provider/audio_service_provider.dart';
import 'package:music_tech/core/utils/helper.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MusicPlayerPage extends StatefulWidget {
  final SearchModel music;
  final int index;

  const MusicPlayerPage({
    super.key,
    required this.music,
    this.index = 0,
  });

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final YoutubeExplode _yt = YoutubeExplode();
  // bool isLoading = false;
  // late SearchModel music;

  @override
  void initState() {
    super.initState();
    final audioServiceProvider = Provider.of<AudioServiceProvider>(
      context,
      listen: false,
    );

    audioServiceProvider.currentMusic = widget.music;
    final music = audioServiceProvider.currentMusic ?? widget.music;
    _playAudioFromYouTube(music.videoId ?? "");
  }

  Future<void> _playAudioFromYouTube(String videoId) async {
    try {
      final audioServiceProvider = Provider.of<AudioServiceProvider>(
        context,
        listen: false,
      );

      // setState(() {
      //   isLoading = true;
      // });
      final music = audioServiceProvider.currentMusic ?? widget.music;

      await audioServiceProvider.playAudioFromYouTube(videoId, music);
    } catch (e) {
      //
    }
    // setState(() {
    //   isLoading = false;
    // });

    //   // Check if the audio is already playing
    //   if (audioServiceProvider.currentMedia?.videoId == videoId) {
    //     // If the audio is already playing, just resume or toggle play/pause
    //     await audioServiceProvider.audioHandler.play();
    //     return;
    //   }

    //   setState(() {
    //     isLoading = true;
    //   });

    //   var manifest = await _yt.videos.streamsClient.getManifest(videoId);
    //   var audioStreamInfo = manifest.audioOnly.withHighestBitrate();

    //   await audioServiceProvider.loadAndPlay(
    //     audioStreamInfo.url.toString(),
    //     music.name ?? "NA",
    //     music.artist?.name ?? 'Unknown Artist',
    //     music.album?.name ?? 'Unknown Album',
    //     music.thumbnails.isNotEmpty ? music.thumbnails[0].url : null,
    //     music,
    //   );
    // } catch (e) {
    //   Helper.showCustomSnackBar("Error Loading Music");
    // } finally {
    //   setState(() {
    //     isLoading = false;
    //   });
    // }
  }

  @override
  void dispose() {
    // _audioPlayer.dispose();
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioServiceProvider = Provider.of<AudioServiceProvider>(context);
    final playlist = audioServiceProvider.playlist;
    final music = audioServiceProvider.currentMusic ?? widget.music;
    final isLoading = audioServiceProvider.isLoading;

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
                if (music.thumbnails.isNotEmpty) ...[
                  CarouselSlider.builder(
                    itemCount: music.thumbnails.length,
                    options: CarouselOptions(),
                    itemBuilder: (
                      BuildContext context,
                      int itemIndex,
                      int pageViewIndex,
                    ) {
                      final thumbnail = music.thumbnails[itemIndex];
                      return CachedNetworkImage(
                        imageUrl: thumbnail.url ?? "",
                        // height: 200,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  music.name ?? "NA",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Artist: ${music.artist?.name ?? "NA"}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Album: ${music.album?.name ?? "NA"}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                StreamBuilder<Duration?>(
                  stream: audioServiceProvider.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;

                    return StreamBuilder<Duration>(
                      stream: audioServiceProvider.positionStream,
                      builder: (context, positionSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Slider(
                              value: position.inSeconds.toDouble(),
                              min: 0.0,
                              max: duration.inSeconds.toDouble(),
                              onChanged: (value) {
                                audioServiceProvider.audioHandler
                                    .seek(Duration(seconds: value.toInt()));
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(position)),
                                  Text(_formatDuration(duration)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //skip prev
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: audioServiceProvider.currentIndex >= 1
                            ? Colors.white
                            : Colors.grey.shade600,
                        size: 30,
                      ),
                      onPressed: audioServiceProvider.onTapPrev,
                      // onPressed: () {
                      //   if (audioServiceProvider.currentIndex <= 0) return;
                      //   // setState(() {
                      //   //   music =
                      //   //       playlist[audioServiceProvider.currentIndex - 1];
                      //   // });
                      //   audioServiceProvider.updateCurrentMusic(
                      //       playlist[audioServiceProvider.currentIndex - 1]);

                      //   _playAudioFromYouTube(
                      //     playlist[audioServiceProvider.currentIndex - 1]
                      //         .videoId!,
                      //   );
                      //   audioServiceProvider.updateCurrentIndex(
                      //     audioServiceProvider.currentIndex - 1,
                      //   );
                      // },
                    ),
                    // play/pause
                    StreamBuilder<bool>(
                      stream: audioServiceProvider.isPlaying,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            size: 64,
                          ),
                          onPressed: audioServiceProvider.playPause,
                        );
                      },
                    ),
                    //skip next
                    IconButton(
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: audioServiceProvider.currentIndex <
                                audioServiceProvider.playlist.length
                            ? Colors.white
                            : Colors.grey.shade600,
                        size: 30,
                      ),
                      onPressed: audioServiceProvider.onTapNext,
                      // onPressed: () {
                      //   if (audioServiceProvider.currentIndex >=
                      //       playlist.length) {
                      //     // Helper.showCustomSnackBar("no next song");
                      //     return;
                      //   }
                      //   audioServiceProvider.updateCurrentMusic(
                      //       playlist[audioServiceProvider.currentIndex + 1]);
                      //   // setState(() {
                      //   //   music =
                      //   //       playlist[audioServiceProvider.currentIndex + 1];
                      //   // });

                      //   _playAudioFromYouTube(
                      //     playlist[audioServiceProvider.currentIndex + 1]
                      //         .videoId!,
                      //   );
                      //   audioServiceProvider.updateCurrentIndex(
                      //     audioServiceProvider.currentIndex + 1,
                      //   );
                      // },
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.stop),
                    //   onPressed: audioServiceProvider.stop,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isLoading) ...[
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ],
    );
  }

  // Format duration to a readable string
  String _formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0");
  }
}
