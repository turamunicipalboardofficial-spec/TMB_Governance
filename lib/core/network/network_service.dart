import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'client/dio_client.dart';

class NetworkService extends GetxService {
  static NetworkService get to => Get.find();
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = DioClient.create();
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  Future<Response> put(String path, {dynamic data, Options? options}) =>
      _dio.put(path, data: data, options: options);

  Future<Response> delete(String path, {dynamic data, Options? options}) =>
      _dio.delete(path, data: data, options: options);

  Future<Response> patch(String path, {dynamic data, Options? options}) =>
      _dio.patch(path, data: data, options: options);
}
