
part of 'package:popsicle/popsicle.dart';

/// Represents a signal (or state marker) emitted by a [PopsicleState].
/// 
/// PopsicleSignal is used to annotate the "intention" or "phase" of a state change.
/// This can be helpful for middleware, observers, or UI builders to react
/// differently depending on the type of signal being emitted.
class PopsicleSignal {
  final String value;
  const PopsicleSignal._(this.value);

  /// A terminal signal – indicates that the state has reached
  /// its final form and will not change further.
  static const PopsicleSignal done = PopsicleSignal._('done');

  /// Marks the end of a process or lifecycle. Unlike [done], which
  /// implies completion, `end` can represent cancellation or teardown.
  static const PopsicleSignal end = PopsicleSignal._('end');

  /// Represents binding or linking state with an external source.
  /// (formerly `entangle`)
  static const PopsicleSignal bind = PopsicleSignal._('entangle');

  /// Indicates that new data has been emitted into the state.
  static const PopsicleSignal emit = PopsicleSignal._('emit');

  /// Signals the beginning of observation, where consumers start listening
  /// to changes in the state.
  static const PopsicleSignal watch = PopsicleSignal._('observe');

  /// Marks a paused state, where updates are temporarily suspended.
  static const PopsicleSignal pause = PopsicleSignal._('pause');

  /// Represents the initial or passive state of the box.
  static const PopsicleSignal idle = PopsicleSignal._('idle');

  /// Used to indicate a refresh operation, such as re-evaluating or
  /// re-fetching the current state.
  static const PopsicleSignal refresh = PopsicleSignal._('refresh');

  /// Emits an update without any structural change – for example,
  /// re-notifying listeners with the same value.
  static const PopsicleSignal update = PopsicleSignal._('update');

  /// Signals that the state is lagging or behind real-time updates.
  static const PopsicleSignal lag = PopsicleSignal._('lag');

  /// A catch-all signal that can be defined by the user for
  /// custom workflows.
  static const PopsicleSignal custom = PopsicleSignal._('custom');

  /// Factory constructor to create custom signals dynamically.
  factory PopsicleSignal.customSignal(String value) =>
      PopsicleSignal._(value);

  @override
  bool operator ==(Object other) =>
      other is PopsicleSignal && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PopsicleSignal.$value';
}
