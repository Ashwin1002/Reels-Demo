import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reels_demo/core/core.dart';

@Injectable(as: RemoteService)
class RemoteServiceImpl extends RemoteService {
  @override
  Future<Response<dynamic>> getResponse({
    required Dio dio,
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int count, int total)? onRecieveProgress,
  }) async {
    try {
      final response = await dio
          .get(
            '$kBaseUrl/$endPoint',
            queryParameters: queryParameters,
            cancelToken: cancelToken,
            onReceiveProgress: onRecieveProgress,
          )
          .timeout(Duration(seconds: 10));
      return response;
    } on DioException catch (err) {
      throw ServerException(err.message ?? 'Something went wrong');
    }
  }

  @override
  Future<File> download({
    required Dio dio,
    required String url,
    required String savedPath,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int count, int total)? onRecieveProgress,
  }) async {
    try {
      await dio.download(
        url,
        savedPath,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        onReceiveProgress: onRecieveProgress,
      );

      return File(savedPath);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Something went wrong');
    }
  }
}
