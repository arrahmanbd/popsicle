import 'package:popsicle/popsicle.dart';

class DrivingLogic extends PopsicleState<String> {
  DrivingLogic() : super(state: '');
  void check(int age) {
    if (age >= 18) {
      shift('Yes you can Drive');
    } else {
      shift('You are not eligable');
    }
  }
}
