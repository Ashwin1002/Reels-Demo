import 'package:reels_demo/src/reels/domain/repositories/reels_remote_repository.dart';

abstract class UseCase<T, Params> {
  EitherFutureData<T> call(Params params);
}

abstract class NoParamUseCase<T> {
  EitherFutureData<T> call();
}

abstract class UseCaseWithParams<T, Params> {
  Future<T> call(Params params);
}

abstract class UseCaseWithOutParams<T> {
  Future<T> call();
}

abstract class NoParamStreamUseCase<T> {
  Stream<T> call();
}
