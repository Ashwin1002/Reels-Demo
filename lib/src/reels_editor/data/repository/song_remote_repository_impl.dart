import 'dart:developer';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reels_demo/core/network/exceptions.dart';
import 'package:reels_demo/core/network/remote_service_impl.dart';
import 'package:reels_demo/src/reels/domain/repositories/reels_remote_repository.dart';
import 'package:reels_demo/src/reels_editor/data/model/song_model.dart';
import 'package:reels_demo/src/reels_editor/domain/repositories/song_remote_repository.dart';

class SongRemoteRepositoryImpl extends SongRemoteRepository {
  @override
  EitherFutureData<List<SongModel>> getAudios() async {
    try {
      final response = await RemoteServiceImpl().getResponse(
        dio: Dio(),
        endPoint: "songs",
      );
      return right(
        await Isolate.run(
          () async =>
              (response.data as List)
                  .map((e) => SongModel.fromJson(e))
                  .toList(),
        ),
      );
    } catch (e) {
      log("error: $e");
      return left(e is ServerException ? e : ServerException(e.toString()));
    }
  }
}
