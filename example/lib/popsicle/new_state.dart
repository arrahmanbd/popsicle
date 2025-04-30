import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:popsicle/popsicle.dart';

class MyState extends PopsicleState<int> {
  MyState() : super(0);

  @override
  void onInit() {
    if (kDebugMode) {
      print('MyState initialized with value: $state');
    }
  }

  @override
  void onDispose() {
    if (kDebugMode) {
      print('MyState disposed');
    }
  }

  void increment() {
    state++;
    if (kDebugMode) {
      print('MyState incremented to: $state');
    }
  }
}

final int intState = Popsicle.provider<MyState>().state;
final MyState myState = Popsicle.provider<MyState>();

class MyCounterView extends StatelessWidget {
  const MyCounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopsicleWidget<int>(
      provider: () => Popsicle.provider<MyState>(),
      builder: (context, value) => Text('Value: $value'),
    );
  }
}
