import 'package:fpdart/fpdart.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/data/repository/reels_remote_repository_impl.dart';
import 'package:reels_demo/src/reels/domain/entities/reels.dart';
import 'package:reels_demo/src/reels/domain/repositories/reels_remote_repository.dart';

class FetchReelsUsecase extends NoParamUseCase<List<Reels>> {
  final ReelsRemoteRepository _reelsRemoteRepository;

  FetchReelsUsecase() : _reelsRemoteRepository = ReelsRemoteRepositoryImpl();

  @override
  EitherFutureData<List<Reels>> call() async {
    final eitherReels = await _reelsRemoteRepository.fetchReels();

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
          .map((t) => t.map((e) => Reels.fromReelsModel(e)).toList())
          .getOrElse(() => []),
    );
  }
}
