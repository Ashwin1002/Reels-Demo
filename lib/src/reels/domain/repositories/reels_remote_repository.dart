import 'package:fpdart/fpdart.dart';
import 'package:reels_demo/src/reels/data/model/reels_model.dart';

typedef EitherFutureData<T> = Future<Either<Exception, T>>;

abstract class ReelsRemoteRepository {
  EitherFutureData<List<ReelsModel>> fetchReels();
}
