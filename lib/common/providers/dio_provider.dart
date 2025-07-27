import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../managers/dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());
