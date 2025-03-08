import 'package:equatable/equatable.dart';
import 'package:reels_demo/src/reels_editor/data/model/song_model.dart';

class Song extends Equatable {
  final String id;
  final String name;
  final String url;
  final String artist;
  final Duration duration;
  final String album;

  const Song({
    required this.id,
    required this.name,
    required this.url,
    required this.artist,
    required this.duration,
    required this.album,
  });

  bool get isValid => url.startsWith("https");

  factory Song.fakeData() => Song(
    id: "fake-song-id",
    name: "fake song name",
    url: "",
    artist: "fake song artist ft. 2nd artist",
    duration: Duration.zero,
    album: "fake 2025 album",
  );

  factory Song.fromSongModel(SongModel song) {
    if (song.url.startsWith("https")) {
      return Song(
        id: song.id,
        album: song.album,
        artist: song.artist,
        duration: Duration(seconds: song.durationInSec),
        name: song.name,
        url: song.url,
      );
    }
    return Song(
      id: song.id,
      album: "",
      artist: "",
      duration: Duration.zero,
      name: "",
      url: "",
    );
  }

  @override
  List<Object> get props {
    return [id, name, url, artist, duration, album];
  }
}
