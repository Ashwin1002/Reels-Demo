import 'dart:io';

import 'package:dio/dio.dart';

abstract class RemoteService {
  Future<Response<dynamic>> getResponse({
    required Dio dio,
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int count, int total)? onRecieveProgress,
  });

  Future<File> download({
    required Dio dio,
    required String url,
    required String savedPath,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int count, int total)? onRecieveProgress,
  });
}
