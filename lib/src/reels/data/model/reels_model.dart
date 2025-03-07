import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reels_demo/core/core.dart';

part 'reels_model.freezed.dart';
part 'reels_model.g.dart';

@freezed
sealed class ReelsModel with _$ReelsModel {
  const ReelsModel._();
  const factory ReelsModel({
    @Default("") String id,
    @DateTimeConverter() DateTime? createdAt,
    @JsonKey(name: "thumb_nail") @Default("") String thumbnail,
    @JsonKey(name: "video_url") @Default("") String videoUrl,
    @Default(0) int likes,
    @Default(0) int comment,
    @Default(0) int shares,
    @Default(0) int bookmark,
    @JsonKey(name: "page_name") @Default("") String pageName,
    @Default("") String description,
    @JsonKey(name: "hash_tags") @Default([]) List<String> tags,
  }) = _ReelsModel;

  factory ReelsModel.fromJson(Map<String, dynamic> json) =>
      _$ReelsModelFromJson(json);

  factory ReelsModel.fakeData() => ReelsModel(
    id: 'fake-id',
    bookmark: 10,
    comment: 9,
    likes: 1000,
    createdAt: DateTime.now(),
    description: "This is a fake description",
    shares: 2,
    tags: [],
    thumbnail: "",
    videoUrl: "",
    pageName: "Page Title",
  );
}
