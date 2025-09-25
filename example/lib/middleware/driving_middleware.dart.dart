// import 'package:flutter/material.dart';
// import 'package:popsicle/popsicle.dart';

import 'package:popsicle/popsicle.dart';

/// Example: logging middleware
class LoggingMiddleware<T> extends PopsicleMiddlewareBase<T> {
  @override
  T? call(T oldState, T newState) {
    print('Middleware: $oldState -> $newState');
    return newState; // pass along
  }
}
