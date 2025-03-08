import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/data/model/reels_model.dart';
import 'package:reels_demo/src/reels/domain/repositories/reels_remote_repository.dart';
import 'package:reels_demo/src/reels_editor/domain/repositories/upload_remote_repository.dart';

class UploadRemoteRepositoryImpl extends UploadRemoteRepository {
  @override
  EitherFutureData<ReelsModel> uploadReels(ReelsModel reels) async {
    try {
      final payload =
          reels.toJson()..removeWhere(
            (key, value) =>
                value == null ||
                value is Map && value.isEmpty ||
                value is String && value.isEmpty ||
                (value is List) && value.isEmpty,
          );

      log("payload => $payload");
      final response = await RemoteServiceImpl().postResponse(
        dio: Dio(),
        endPoint: "reels",
        payload: payload,
      );
      final result = response.data as Map<String, dynamic>;
      return right(ReelsModel.fromJson(result));
    } catch (e) {
      log("error while uploading reels: $e");
      return left(e is ServerException ? e : ServerException(e.toString()));
    }
  }
}
