part of '../../popsicle.dart';

/// Abstract class for managing a single reactive state with UI binding support.
abstract class PopsicleState<T> {
  T _state;
  final Set<VoidCallback> _listeners = {};
  late final ValueNotifier<T> _notifier;

  PopsicleState(T initialState) : _state = initialState {
    _notifier = ValueNotifier<T>(_state);
    onInit();
  }

  T get state => _state;

  set state(T newValue) {
    if (_state != newValue) {
      _state = newValue;
      _notifier.value = newValue;
      notifyListeners();
    }
  }

  /// Native Flutter binding
  ValueListenable<T> get listenable => _notifier;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        // Optional: handle or log
      }
    }
  }

  /// Called once when the state is initialized.
  void onInit() {}

  /// Called when the state is being disposed.
  void onDispose() {
    _listeners.clear();
    _notifier.dispose();
  }

  void dispose() => onDispose();
}

/// Extension for PopsicleState to provide a convenient way to listen to state changes.
/// This extension allows you to use the `listen` method to create a widget
extension PopsicleExtensions<T> on PopsicleState<T> {
  Widget view(Widget Function(T value) builder) {
    return ValueListenableBuilder<T>(
      valueListenable: listenable,
      builder: (_, value, __) => builder(value),
    );
  }
}

/// Widget for PopsicleState to provide a convenient way to listen to state changes.

typedef PopsicleBuilder<T> = Widget Function(BuildContext context, T value);

class PopsicleWidget<T> extends StatelessWidget {
  final PopsicleState<T> Function() provider;
  final PopsicleBuilder<T> builder;

  const PopsicleWidget({
    super.key,
    required this.provider,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final state = provider();
    return ValueListenableBuilder<T>(
      valueListenable: state.listenable,
      builder: (context, value, _) => builder(context, value),
    );
  }
}
