
import 'package:popsicle/popsicle.dart';

class DrivingLogic extends PopsicleState<int> {
  DrivingLogic() : super(state: 0);

  void setAge(int age) => shift(age);
}
