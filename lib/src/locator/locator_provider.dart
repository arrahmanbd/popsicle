// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'package:popsicle/popsicle.dart';

class Popsicle {
  static final init = PopsicleLocator.instance;
  static void bootStrap(PopsicleServices di) {
    di(init);
  }

  /// Helper to get registered lazy singleton
  static T get<T extends Object>() => init.get<T>();
}
// class ServiceLocation {
//   ServiceLocation._private();
//   static final instance = ServiceLocation._private();

//   final _singletons = <Type, Object>{};
//   final _lazyFactories = <Type, FactoryFunc>{};
//   final _asyncLazyFactories = <Type, FactoryFuncAsync>{};
//   final _readyCompleters = <Type, Completer>{};
// //popsicle

//   /// Register a regular singleton
//   void registerSingleton<T extends Object>(T instance) {
//     _singletons[T] = instance;
//   }

//   /// Register a lazy singleton (created on first access)
//   void registerLazySingleton<T extends Object>(FactoryFunc<T> factory) {
//     _lazyFactories[T] = factory;
//   }

//   /// Register an async lazy singleton
//   void registerLazySingletonAsync<T extends Object>(FactoryFuncAsync<T> factory) {
//     _asyncLazyFactories[T] = factory;
//     _readyCompleters[T] = Completer<T>();
//   }

//   /// Get an instance
//   T get<T extends Object>() {
//     if (_singletons.containsKey(T)) return _singletons[T] as T;

//     if (_lazyFactories.containsKey(T)) {
//       final factory = _lazyFactories.remove(T)!;
//       final instance = factory();
//       _singletons[T] = instance;
//       return instance;
//     }

//     throw Exception("Type $T not registered.");
//   }

//   /// Get async instance (waits if lazy async singleton)
//   Future<T> getAsync<T extends Object>() async {
//     if (_singletons.containsKey(T)) return _singletons[T] as T;

//     if (_asyncLazyFactories.containsKey(T)) {
//       final factory = _asyncLazyFactories.remove(T)!;
//       final instance = await factory();
//       _singletons[T] = instance;
//       _readyCompleters[T]!.complete(instance);
//       return instance;
//     }

//     throw Exception("Type $T not registered as async.");
//   }

//   /// Wait for a type to be ready (only for async lazy singletons)
//   Future<void> isReady<T extends Object>() async {
//     if (_singletons.containsKey(T)) return;
//     if (_readyCompleters.containsKey(T)) await _readyCompleters[T]!.future;
//   }

//   /// Reset everything (useful for testing)
//   void reset() {
//     _singletons.clear();
//     _lazyFactories.clear();
//     _asyncLazyFactories.clear();
//     _readyCompleters.clear();
//   }
// }
