import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_tech/core/provider/audio_service_provider.dart';
import 'package:music_tech/core/utils/helper.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioServiceProvider audioServiceProvider;

  AudioPlayer get audioPlayer => _audioPlayer;

  AudioPlayerHandler(this.audioServiceProvider) {
    _audioPlayer.playerStateStream.listen(_broadcastState);
    _audioPlayer.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        mediaItem.add(mediaItem.value?.copyWith(duration: duration));
      }
    });
  }

  void _broadcastState(PlayerState playerState) {
    final isPlaying = playerState.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[playerState.processingState]!,
      playing: isPlaying,
      updatePosition: _audioPlayer.position,
    ));
  }

  @override
  Future<void> play() => _audioPlayer.play();
  @override
  Future<void> pause() => _audioPlayer.pause();
  @override
  Future<void> stop() => _audioPlayer.stop();
  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);
  // @override
  // Future<void> skipToNext() => _audioPlayer.seekToNext();
  @override
  Future<void> skipToPrevious() async {
    await audioServiceProvider.onTapPrev();
  }

  @override
  Future<void> skipToNext() async {
    await audioServiceProvider.onTapNext();
    // print(audioServiceProvider.playlist.length);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    try {
      if (name == 'loadMedia') {
        final url = extras?['url'] ?? "";

        await _audioPlayer.setUrl(url);

        final duration = _audioPlayer.duration;
        Uri? artUri = extras?['thumbnail'] != null
            ? Uri.parse(extras!['thumbnail'])
            : null;

        mediaItem.add(MediaItem(
          id: url,
          album: extras?['album'] ?? "Unknown Album",
          title: extras?['title'] ?? "Unknown Title",
          artist: extras?['artist'] ?? "Unknown Artist",
          duration: duration,
          artUri: artUri,
        ));
      }
    } catch (e) {
      Helper.showCustomSnackBar("Unknown error on Music Action");
    }
  }
}
