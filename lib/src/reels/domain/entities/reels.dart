import 'package:equatable/equatable.dart';
import 'package:reels_demo/core/extensions/extensions.dart';
import 'package:reels_demo/src/reels/data/model/reels_model.dart';

class Reels extends Equatable {
  final String id;
  final String thumbnail;
  final String videoUrl;
  final String name;
  final String description;
  final int like;
  final int comment;
  final int share;
  final int bookmark;

  const Reels({
    required this.id,
    required this.bookmark,
    required this.comment,
    required this.description,
    required this.like,
    required this.name,
    required this.share,
    required this.thumbnail,
    required this.videoUrl,
  });

  bool get isValid => thumbnail.isValidImageUrl && videoUrl.isValidVideoUrl;

  factory Reels.fromReelsModel(ReelsModel reels) {
    if (reels.videoUrl.isValidVideoUrl && reels.thumbnail.isValidImageUrl) {
      return Reels(
        id: reels.id,
        bookmark: reels.bookmark,
        comment: reels.comment,
        description:
            "${reels.description} ${reels.tags.map((e) => "#$e").join(" ")}",
        like: reels.likes,
        name: reels.pageName,
        share: reels.shares,
        thumbnail: reels.thumbnail,
        videoUrl: reels.videoUrl,
      );
    }
    return Reels(
      id: reels.id,
      bookmark: reels.bookmark,
      comment: reels.comment,
      description:
          "${reels.description} ${reels.tags.map((e) => "#$e").join(" ")}",
      like: reels.likes,
      name: reels.pageName,
      share: reels.shares,
      thumbnail: "",
      videoUrl: "",
    );
  }

  @override
  List<Object?> get props => [
    bookmark,
    comment,
    description,
    like,
    name,
    share,
    thumbnail,
    videoUrl,
    id,
  ];
}
