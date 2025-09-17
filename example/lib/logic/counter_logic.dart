
import 'package:popsicle/popsicle.dart';

class CounterLogic extends PopsicleState<int> {
  CounterLogic() : super(state: 0);

  void increment() => shift(state ++);
  void decrement() => shift(state --);
}
