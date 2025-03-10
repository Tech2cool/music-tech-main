import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_tech/core/models/search_model.dart';
import 'package:music_tech/core/provider/audio_service_provider.dart';
import 'package:music_tech/pages/artist_info_page.dart';
import 'package:music_tech/pages/music_player_page.dart';
import 'package:music_tech/pages/playlist_info_page.dart';
import 'package:provider/provider.dart';

class AlbumInfoPage extends StatefulWidget {
  final SearchModel music;
  const AlbumInfoPage({super.key, required this.music});

  @override
  State<AlbumInfoPage> createState() => _AlbumInfoPageState();
}

class _AlbumInfoPageState extends State<AlbumInfoPage> {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchPlayList();
  }

  fetchPlayList() async {
    final audioServiceProvider = Provider.of<AudioServiceProvider>(
      context,
      listen: false,
    );
    try {
      setState(() {
        isLoading = true;
      });
      await audioServiceProvider.getAlbumById(widget.music);
    } catch (e) {
      //
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioServiceProvider = Provider.of<AudioServiceProvider>(context);
    final playlist = audioServiceProvider.currentAlbumInfo?.songs ?? [];
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Album"),
          ),
          body: ListView(
            children: [
              if (widget.music.thumbnails.isNotEmpty) ...[
                CarouselSlider.builder(
                  itemCount: widget.music.thumbnails.length,
                  options: CarouselOptions(
                    aspectRatio: 9 / 5,
                    autoPlay: true,
                  ),
                  itemBuilder: (
                    BuildContext context,
                    int itemIndex,
                    int pageViewIndex,
                  ) {
                    final thumbnail = widget.music.thumbnails[itemIndex];
                    return CachedNetworkImage(
                      imageUrl: thumbnail.url ?? "",
                      // height: 200,
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              Text(
                widget.music.name ?? "NA",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Artist: ${widget.music.artist?.name ?? "NA"}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Album: ${widget.music.album?.name ?? "NA"}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Year: ${widget.music.year ?? "NA"}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Divider(
                color: Colors.grey.withOpacity(0.3),
              ),
              if (playlist.isNotEmpty)
                ...List.generate(
                  playlist.length,
                  (index) {
                    final song = playlist[index];
                    return ListTile(
                      minVerticalPadding: 10,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      title: Text(
                        song.name ?? "NA",
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      subtitle: Text(
                        maxLines: 1,
                        song.album?.name ?? song.artist?.name ?? "NA",
                      ),
                      leading: SizedBox(
                        width: 80,
                        height: 80,
                        child: CachedNetworkImage(
                          imageUrl: (song.thumbnails.isNotEmpty
                              ? song.thumbnails.length > 1
                                  ? song.thumbnails[1].url ?? ""
                                  : song.thumbnails[0].url ?? ""
                              : "https://static-00.iconduck.com/assets.00/no-image-icon-512x512-lfoanl0w.png"),
                          errorWidget: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.play_circle_fill_rounded,
                        size: 40,
                      ),
                      onTap: () {
                        if (song.type == "PLAYLIST") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayListInfoPage(
                                music: song,
                              ),
                            ),
                          );
                        } else if (song.type == "ARTIST") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistInfoPage(
                                music: song,
                              ),
                            ),
                          );
                        } else if (song.type == "ALBUM") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumInfoPage(
                                music: song,
                              ),
                            ),
                          );
                        } else {
                          audioServiceProvider.playlist = playlist;
                          audioServiceProvider.currentIndex = index;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MusicPlayerPage(
                                music: song,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                )
              else ...[
                const Text(
                  "Album is Empty",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ],
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
}
