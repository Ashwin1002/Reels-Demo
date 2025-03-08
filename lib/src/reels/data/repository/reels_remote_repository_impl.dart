import 'dart:developer';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/data/model/reels_model.dart';
import 'package:reels_demo/src/reels/domain/repositories/reels_remote_repository.dart';

@Injectable(as: ReelsRemoteRepository)
class ReelsRemoteRepositoryImpl extends ReelsRemoteRepository {
  @override
  EitherFutureData<List<ReelsModel>> fetchReels() async {
    try {
      final response = await RemoteServiceImpl().getResponse(
        dio: Dio(),
        endPoint: "reels",
      );
      return right(
        await Isolate.run(
          () async =>
              (response.data as List)
                  .map((e) => ReelsModel.fromJson(e))
                  .toList(),
        ),
      );
    } catch (e) {
      log("error: $e");
      return left(e is ServerException ? e : ServerException(e.toString()));
    }
  }
}
