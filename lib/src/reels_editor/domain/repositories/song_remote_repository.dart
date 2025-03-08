import 'package:reels_demo/src/reels/domain/repositories/reels_remote_repository.dart';
import 'package:reels_demo/src/reels_editor/data/model/song_model.dart';

abstract class SongRemoteRepository {
  EitherFutureData<List<SongModel>> getAudios();
}
