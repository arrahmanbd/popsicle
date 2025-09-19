import 'package:popsicle/popsicle.dart';

class CounterLogic extends PopsicleState<int> {
  CounterLogic() : super(state: 0);
  void increment() => shift(state+1);
  void decrement() => shift(state-1);
}
