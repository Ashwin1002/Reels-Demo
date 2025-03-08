import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reels_demo/core/core.dart';

part 'song_model.freezed.dart';
part 'song_model.g.dart';

@freezed
sealed class SongModel with _$SongModel {
  const SongModel._();
  const factory SongModel({
    @Default("") String id,
    @DateTimeConverter() DateTime? createdAt,
    @JsonKey(name: "song_name") @Default("") String name,
    @JsonKey(name: "artist") @Default("") String artist,
    @Default("") String album,
    @JsonKey(name: "duration_in_secs") @Default(0) int durationInSec,
    @JsonKey(name: "release_year") @Default(0) int releaseYear,
    @JsonKey(name: "song_url") @Default("") String url,
    @JsonKey(name: "local_path") @Default("") String localPath,
  }) = _SongModel;

  factory SongModel.fromJson(Map<String, dynamic> json) =>
      _$SongModelFromJson(json);

  factory SongModel.fakeData() =>
      SongModel(id: 'fake-id', createdAt: DateTime.now());
}
