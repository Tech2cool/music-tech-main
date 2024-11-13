import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerHandler() {
    _audioPlayer.playerStateStream.listen(_broadcastState);
    _audioPlayer.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });
  }

  void _broadcastState(PlayerState playerState) {
    final isPlaying = playerState.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.rewind,
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
        MediaControl.fastForward,
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
  @override
  Future<void> skipToNext() => _audioPlayer.seekToNext();
  @override
  Future<void> skipToPrevious() => _audioPlayer.seekToPrevious();

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'loadMedia') {
      final url = extras!['url'] as String;
      await _audioPlayer.setUrl(url);
      final duration = _audioPlayer.duration;
      mediaItem.add(MediaItem(
        id: url,
        album: extras['album'] ?? "Unknown Album",
        title: extras['title'] ?? "Unknown Title",
        artist: extras['artist'] ?? "Unknown Artist",
        duration: duration,
      ));
    }
  }
}
