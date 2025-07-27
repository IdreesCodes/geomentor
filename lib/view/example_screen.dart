import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/example_vm.dart';

class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(exampleDataProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Example MVVM + Dio + Riverpod')),
      body: Center(
        child: dataAsync.when(
          data: (data) => Text(data),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }
}
