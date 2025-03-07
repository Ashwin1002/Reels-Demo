import 'package:dio/dio.dart';

abstract class RemoteService {
  Future<dynamic> getResponse({
    required Dio dio,
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int count, int total)? onRecieveProgress,
  });
}
