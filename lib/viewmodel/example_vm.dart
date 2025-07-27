import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/providers/dio_provider.dart';
import 'package:dio/dio.dart';

final exampleDataProvider = FutureProvider<String>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final response = await dioClient.get(
    'https://jsonplaceholder.typicode.com/todos/1',
  );
  return response.data.toString();
});
