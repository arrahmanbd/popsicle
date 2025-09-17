part of 'package:popsicle/popsicle.dart';

/// 🍭 Popsicle UI Extensions
///
/// These extensions simplify observing and reacting to `PopsicleState`
/// inside Flutter widgets. They let you bind state to UI updates
/// in a declarative and reactive way.
///
/// Includes:
/// - `freezeView`: Create read-only state
/// - `lick`: Bind state directly to a widget
/// - `bite`: React with both state & signal
/// - `taste` / `tasteWithSignal`: Context helpers
/// - `frozen`: Safe read-only observation
///

/// ❄️ Extension to freeze a PopsicleState into read-only mode.
extension PopsicleFreezeExtension<T> on PopsicleState<T> {
  /// Creates a frozen (read-only) version of this state.
  ///
  /// Example:
  /// ```dart
  /// final frozenCounter = counterState.freezeView();
  /// ```
  PopsicleState<T> freezeView() => ReadonlyState<T>(this);
}

/// 🍬 Extensions to bind state directly inside widgets.
extension PopsicleObserveX<T> on PopsicleState<T> {
  /// Lick 🍭 — observes this state and rebuilds UI when it emits a new value.
  ///
  /// Example:
  /// ```dart
  /// counterState.lick((value) => Text('$value'));
  /// ```
  Widget lick(Widget Function(T value) builder) {
    return PopsicleObserver<T>(
      waveform: this,
      builder: (context, value) => builder(value),
    );
  }

  /// Bite 🍫 — observes this state and rebuilds UI using both value and signal.
  ///
  /// Useful when you need to differentiate based on signal type
  /// (e.g., `emit`, `resonate`, or `collapse`).
  ///
  /// Example:
  /// ```dart
  /// counterState.bite((value, signal) {
  ///   return Text('$value - $signal');
  /// });
  /// ```
  Widget bite(Widget Function(T? value, PopsicleSignal signal) builder) {
    return PopsicleObserver<T>(
      waveform: this,
      builderWithSignal: (context, value, signal) => builder(value, signal),
      builder: (BuildContext context, T? state) => const SizedBox.shrink(),
    );
  }
}

/// 🍦 Context extensions for ergonomic state observation.
extension PopsicleContextExtensions on BuildContext {
  /// Taste 🍓 — observes a [PopsicleState] and rebuilds the widget on state changes.
  ///
  /// Example:
  /// ```dart
  /// context.taste(counterState, (value) => Text('$value'));
  /// ```
  Widget taste<T>(PopsicleState<T> state, Widget Function(T? state) builder) {
    return PopsicleObserver<T>(
      waveform: state,
      builder: (_, value) => builder(value),
    );
  }

  /// Taste With Signal 🍪 — observes a [PopsicleState] with state + signal.
  ///
  /// Example:
  /// ```dart
  /// context.tasteWithSignal(
  ///   counterState,
  ///   (value, signal) => Text('$value - $signal'),
  /// );
  /// ```
  Widget tasteWithSignal<T>(
    PopsicleState<T> state,
    Widget Function(T? value, PopsicleSignal signal) builder,
  ) {
    return PopsicleObserver<T>(
      waveform: state,
      builderWithSignal: (_, value, signal) => builder(value, signal),
      builder: (BuildContext context, T? value) => const SizedBox.shrink(),
    );
  }

  /// Frozen 🍧 — observes a [PopsicleState] in read-only mode.
  ///
  /// Useful for UI that should **react** but never **mutate**.
  ///
  /// Example:
  /// ```dart
  /// context.frozen(counterState, (value) => Text('$value'));
  /// ```
  Widget frozen<T>(PopsicleState<T> state, Widget Function(T? state) builder) {
    return PopsicleObserver<T>(
      waveform: state.freezeView(),
      builder: (_, value) => builder(value),
    );
  }
}
