import 'package:flutter_riverpod/flutter_riverpod.dart';

// compare with riverpod
final drivingProvider = NotifierProvider<DriviNotifier, String>(
  DriviNotifier.new,
);

class DriviNotifier extends Notifier<String> {
  DriviNotifier() : super();

  @override
  build() {
    return '';
  }

  void check(int age) {
    if (age >= 18) {
      state = 'Yes, you can drive';
    } else {
      state = 'You are not eligible';
    }
  }
}
