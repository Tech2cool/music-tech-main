import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_tech/core/models/home_suggestion.dart';
import 'package:music_tech/core/models/search_model.dart';
import 'package:music_tech/core/services/api_service.dart';
import 'package:music_tech/core/services/audio_player_handler.dart';
import 'package:music_tech/core/utils/helper.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioServiceProvider with ChangeNotifier {
  late final AudioPlayerHandler _audioHandler;
  final ApiService _apiService = ApiService();
  final YoutubeExplode _yt = YoutubeExplode();

  SearchModel? currentMusic;
  SearchModel? _currentMedia;
  SearchModel? _currentPlayList;
  SearchModel? _currentArtist;
  SearchModel? _currentArtistInfo;
  SearchModel? _currentAlbumInfo;
  SearchModel? _currentAlbum;

  AudioPlayerHandler get audioHandler => _audioHandler;
  SearchModel? get currentMedia => _currentMedia;
  SearchModel? get currentPlayList => _currentPlayList;
  SearchModel? get currentArtist => _currentArtist;
  SearchModel? get currentArtistInfo => _currentArtistInfo;
  SearchModel? get currentAlbumInfo => _currentAlbumInfo;
  SearchModel? get currentAlbum => _currentAlbum;

  List<SearchModel> playlist = [];
  List<SearchModel> albumList = [];
  List<SearchModel> searchResult = [];
  List<HomeSuggestion> homeResults = [];

  int currentIndex = 0;
  bool isLoading = false;

  Stream<bool> get isPlaying =>
      _audioHandler.playbackState.map((state) => state.playing).distinct();
  Stream<Duration> get positionStream =>
      _audioHandler.audioPlayer.positionStream;
  Stream<Duration?> get durationStream =>
      _audioHandler.audioPlayer.durationStream;

  Future<void> init(AudioServiceProvider provider) async {
    _audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(provider),
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

  updateCurrentMusic(SearchModel index) {
    currentMusic = index;
    notifyListeners();
  }

  onTapPrev() {
    if (currentIndex <= 0) return;
    final currndex = currentIndex - 1;

    updateCurrentMusic(playlist[currndex]);
    currentIndex -= 1;
    notifyListeners();

    playAudioFromYouTube(
      playlist[currndex].videoId!,
      playlist[currndex],
    );
    notifyListeners();
  }

  onTapNext() {
    if (currentIndex >= playlist.length) {
      // Helper.showCustomSnackBar("no next song");
      return;
    }
    final currndex = currentIndex + 1;
    updateCurrentMusic(playlist[currndex]);
    currentIndex += 1;
    notifyListeners();

    playAudioFromYouTube(
      playlist[currndex].videoId!,
      playlist[currndex],
    );
    notifyListeners();
  }

  Future<void> playAudioFromYouTube(String videoId, SearchModel music) async {
    try {
      // Check if the audio is already playing
      if (currentMedia?.videoId == videoId) {
        // If the audio is already playing, just resume or toggle play/pause
        await audioHandler.play();
        return;
      }
      isLoading = true;
      Future.microtask(() => notifyListeners());

      // setState(() {
      //   isLoading = true;
      // });

      var manifest = await _yt.videos.streamsClient.getManifest(videoId);
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      await loadAndPlay(
        audioStreamInfo.url.toString(),
        music.name ?? "NA",
        music.artist?.name ?? 'Unknown Artist',
        music.album?.name ?? 'Unknown Album',
        music.thumbnails.isNotEmpty ? music.thumbnails[0].url : null,
        music,
      );
    } catch (e) {
      Helper.showCustomSnackBar("Error Loading Music");
    } finally {
      //
    }
    isLoading = false;
    Future.microtask(() => notifyListeners());
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
      try {
        await _audioHandler.stop();
      } catch (e) {
        //
      }
      Map<String, dynamic> extra = {
        "url": url,
        "title": name,
        "artist": artist,
        "album": album,
        "thumbnail": thumbnail,
      };
      await _audioHandler.customAction("loadMedia", extra);
      _currentMedia = media;
      try {
        await _audioHandler.play().timeout(const Duration(seconds: 2));
      } catch (e) {
        //
      }
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

  Future<void> getHomeSuggestion() async {
    final results = await _apiService.getHomeData();

    homeResults = results;
    print(results);
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

  Future<void> getAlbumById(SearchModel music) async {
    final resp = await _apiService.getAlbumById(music.albumId!);
    _currentAlbumInfo = resp;
    _currentAlbum = music;
    notifyListeners();
  }

  //reset values
  void resetSearch() {
    searchResult = [];
    notifyListeners();
  }
}
