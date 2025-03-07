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
}
