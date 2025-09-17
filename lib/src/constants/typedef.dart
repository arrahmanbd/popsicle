part of 'package:popsicle/popsicle.dart';


typedef PopsicleBuilder<T> = Widget Function(BuildContext context, T state);


typedef PopsicleBuilderWithEntangle<T> =
    Widget Function(BuildContext context, T? state, PopsicleSignal signal);


typedef PopsicleBuilderWithLogic<T, L extends PopsicleState<T>> =
    Widget Function(BuildContext context, T value, L logic);

 typedef QuantumMiddleware<T> = T? Function(T current, T next);
