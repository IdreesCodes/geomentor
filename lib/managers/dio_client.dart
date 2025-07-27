import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient({Dio? dio}) : dio = dio ?? Dio();

  // Example GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  // Add other HTTP methods as needed (post, put, delete, etc.)
}
