part of 'package:popsicle/popsicle.dart';

extension PopLogic on Object {
  static T use<T extends Object>() => Popsicle.get<T>();
}

T useLogic<T extends Object>() => Popsicle.get<T>();
