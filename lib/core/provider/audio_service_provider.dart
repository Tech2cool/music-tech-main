import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_tech/core/models/search_model.dart';
import 'package:music_tech/core/services/api_service.dart';
import 'package:music_tech/core/services/audio_player_handler.dart';

class AudioServiceProvider with ChangeNotifier {
  late final AudioPlayerHandler _audioHandler;
  final ApiService _apiService = ApiService();
  SearchModel? _currentMedia;
  SearchModel? _currentPlayList;
  SearchModel? _currentArtist;
  SearchModel? _currentArtistInfo;

  AudioPlayerHandler get audioHandler => _audioHandler;
  SearchModel? get currentMedia => _currentMedia;
  SearchModel? get currentPlayList => _currentPlayList;
  SearchModel? get currentArtist => _currentArtist;
  SearchModel? get currentArtistInfo => _currentArtistInfo;
  List<SearchModel> playlist = [];
  List<SearchModel> searchResult = [];
  int currentIndex = 0;

  Stream<bool> get isPlaying =>
      _audioHandler.playbackState.map((state) => state.playing).distinct();
  Stream<Duration> get positionStream =>
      _audioHandler.audioPlayer.positionStream;
  Stream<Duration?> get durationStream =>
      _audioHandler.audioPlayer.durationStream;

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

  updateCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future<void> loadAndPlay(
    String url, [
    String name = "NA",
    String artist = "NA",
    String album = "NA",
    String? thumbnail,
    SearchModel? media,
  ]) async {
    try {
      await _audioHandler.stop();
      Map<String, dynamic> extra = {
        "url": url,
        "title": name,
        "artist": artist,
        "album": album,
        "thumbnail": thumbnail,
      };
      await _audioHandler.customAction("loadMedia", extra);
      _currentMedia = media;
      _audioHandler.play().timeout(const Duration(seconds: 2));
    } catch (e) {
      // Handle error
    } finally {
      notifyListeners();
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

  //api calls
  Future<void> searchMusic(String query, String selectedFilter) async {
    final results = await _apiService.searchSongs(query, selectedFilter);
    searchResult = results;
    notifyListeners();
  }

  Future<void> getPlayListByid(SearchModel music) async {
    final resp = await _apiService.getPlayListById(music.playlistId!);
    playlist = resp;
    _currentArtist = music;
    notifyListeners();
  }

  Future<void> getArtistByid(SearchModel music) async {
    final resp = await _apiService.getArtistById(music.artistId!);
    _currentArtistInfo = resp;
    _currentArtist = music;
    notifyListeners();
  }

  //reset values
  void resetSearch() {
    searchResult = [];
    notifyListeners();
  }
}
