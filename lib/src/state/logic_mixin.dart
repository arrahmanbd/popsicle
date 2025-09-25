part of 'package:popsicle/popsicle.dart';

extension PopsicleStateX<TLogic extends _BasePopsicleState> on TLogic {
  /// Access the registered instance from the locator
  static TLogic of<TLogic extends _BasePopsicleState>() {
    return Popsicle.get<TLogic>();
  }
}
// Exaple:

// final age = Logical<int>(state: 0);

// age.addListener(() {
//   print('Age changed to ${age.value}');
// });

// age.value = 10; // prints: Age changed to 10
// age.update((v) => v + 1); // prints: Age changed to 11

/// A reactive value wrapper
/// -----------------------------
/// Logical wrapper for reactive variables
/// -----------------------------
class Logical<T> extends _BasePopsicleState<T> {
  Logical({required super.state});

  T get value => state;
  set value(T newValue) => shift(newValue);
}
