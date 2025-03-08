import 'package:reels_demo/src/reels/data/model/reels_model.dart';
import 'package:reels_demo/src/reels/domain/repositories/reels_remote_repository.dart';

abstract class UploadRemoteRepository {
  EitherFutureData<ReelsModel> uploadReels(ReelsModel reels);
}
