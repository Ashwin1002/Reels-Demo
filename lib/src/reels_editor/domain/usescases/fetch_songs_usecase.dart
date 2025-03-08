import 'package:fpdart/fpdart.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/domain/repositories/reels_remote_repository.dart';
import 'package:reels_demo/src/reels_editor/data/repository/song_remote_repository_impl.dart';
import 'package:reels_demo/src/reels_editor/domain/entities/song.dart';
import 'package:reels_demo/src/reels_editor/domain/repositories/song_remote_repository.dart';

class FetchSongsUsecase extends NoParamUseCase<List<Song>> {
  final SongRemoteRepository _remoteRepository;

  FetchSongsUsecase() : _remoteRepository = SongRemoteRepositoryImpl();

  @override
  EitherFutureData<List<Song>> call() async {
    final eitherReels = await _remoteRepository.getAudios();

    if (eitherReels.isLeft()) {
      return left(
        eitherReels.getLeft().getOrElse(
          () => ServerException("Something went wrong"),
        ),
      );
    }

    return right(
      eitherReels
          .getRight()
          .map((t) => t.map((e) => Song.fromSongModel(e)).toList())
          .getOrElse(() => []),
    );
  }
}
