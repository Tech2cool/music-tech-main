import 'dart:convert';

class SearchModel {
  final String type;
  final String? videoId;
  final String? artistId;
  final String name;
  final Artist? artist;
  final Album? album;
  final int? duration;
  final List<Thumbnail> thumbnails;

  SearchModel({
    required this.type,
    required this.videoId,
    required this.artistId,
    required this.name,
    required this.artist,
    required this.album,
    this.duration,
    required this.thumbnails,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'videoId': videoId,
      'artistId': artistId,
      'name': name,
      'artist': artist?.toMap(),
      'album': album?.toMap(),
      'duration': duration,
      'thumbnails': thumbnails.map((x) => x.toMap()).toList(),
    };
  }

  factory SearchModel.fromMap(Map<String, dynamic> map) {
    return SearchModel(
      type: map['type'],
      videoId: map['videoId'],
      artistId: map['artistId'],
      name: map['name'],
      artist: map['artist'] != null ? Artist.fromMap(map['artist']) : null,
      album: map['album'] != null ? Album.fromMap(map['album']) : null,
      duration: map['duration'],
      thumbnails: (map["thumbnails"] as List<dynamic>?)
              ?.map((ele) => Thumbnail.fromMap(ele as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory SearchModel.fromJson(String source) =>
      SearchModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Artist {
  final String? name;
  final String? artistId;

  Artist({
    required this.name,
    required this.artistId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'artistId': artistId,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      name: map['name'] != null ? map['name'] as String : null,
      artistId: map['artistId'] != null ? map['artistId'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Artist.fromJson(String source) =>
      Artist.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Album {
  final String? name;
  final String? albumId;

  Album({
    required this.name,
    required this.albumId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'albumId': albumId,
    };
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      name: map['name'] != null ? map['name'] as String : null,
      albumId: map['albumId'] != null ? map['albumId'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Album.fromJson(String source) =>
      Album.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Thumbnail {
  final String? url;
  final int? width;
  final int? height;

  Thumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'width': width,
      'height': height,
    };
  }

  factory Thumbnail.fromMap(Map<String, dynamic> map) {
    return Thumbnail(
      url: map['url'] != null ? map['url'] as String : null,
      width: map['width'] != null ? map['width'] as int : null,
      height: map['height'] != null ? map['height'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Thumbnail.fromJson(String source) =>
      Thumbnail.fromMap(json.decode(source) as Map<String, dynamic>);
}
