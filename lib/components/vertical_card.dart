import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_tech/core/models/search_model.dart';
import 'package:music_tech/core/provider/audio_service_provider.dart';
import 'package:music_tech/pages/album_info_page.dart';
import 'package:music_tech/pages/artist_info_page.dart';
import 'package:music_tech/pages/music_player_page.dart';
import 'package:music_tech/pages/playlist_info_page.dart';
import 'package:provider/provider.dart';

class VerticalCard extends StatelessWidget {
  final SearchModel record;
  final List<SearchModel> list;
  const VerticalCard({super.key, required this.record, required this.list});

  @override
  Widget build(BuildContext context) {
    final audioServiceProvider = Provider.of<AudioServiceProvider>(context);

    final thumbnail = record.thumbnails.isNotEmpty
        ? record.thumbnails.length > 1
            ? record.thumbnails[1].url
            : record.thumbnails[0].url
        : null;
    return GestureDetector(
      onTap: () {
        if (record.type == "PLAYLIST") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayListInfoPage(
                music: record,
              ),
            ),
          );
        } else if (record.type == "ARTIST") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtistInfoPage(
                music: record,
              ),
            ),
          );
        } else if (record.type == "ALBUM") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumInfoPage(
                music: record,
              ),
            ),
          );
        } else {
          audioServiceProvider.playlist = list;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MusicPlayerPage(
                music: record,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: thumbnail ?? "",
              width: 120,
              fit: BoxFit.fitHeight,
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(100)),
                  ],
                ),
                child: Text(
                  record.type,
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
