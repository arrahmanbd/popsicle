
part of '../../popsicle.dart';



class ReactiveScopeManager {
  static final Map<String, ReactiveScope> _scopes = {};

  static ReactiveScope scope(String name) {
    return _scopes.putIfAbsent(name, () => ReactiveScope());
  }

  static void disposeScope(String name) {
    _scopes[name]?.disposeAll();
    _scopes.remove(name);
  }

  static void disposeAll() {
    for (final scope in _scopes.values) {
      scope.disposeAll();
    }
    _scopes.clear();
  }
}
