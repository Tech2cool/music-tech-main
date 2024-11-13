import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_tech/core/services/audio_player_handler.dart';

class AudioServiceProvider with ChangeNotifier {
  late final AudioHandler _audioHandler;

  AudioHandler get audioHandler => _audioHandler;

  Stream<bool> get isPlaying =>
      _audioHandler.playbackState.map((state) => state.playing).distinct();

  Future<void> init() async {
    _audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.audio.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );
  }

  Future<void> loadAndPlay(String url) async {
    try {
      await _audioHandler.stop();
      await _audioHandler.customAction('loadMedia', {'url': url});
      await _audioHandler.play();
    } catch (e) {
      print('Error loading and playing audio: $e');
      // Handle error (e.g., show a snackbar to the user)
    }
  }

  void playPause() {
    if (_audioHandler.playbackState.value.playing) {
      _audioHandler.pause();
    } else {
      _audioHandler.play();
    }
    notifyListeners();
  }

  void stop() {
    _audioHandler.stop();
    notifyListeners();
  }
}
