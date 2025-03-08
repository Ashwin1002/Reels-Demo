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

  Future<Response<dynamic>> postResponse({
    required Dio dio,
    required String endPoint,
    Object? payload,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int count, int total)? onUploadProgress,
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
