import 'package:popsicle/popsicle.dart';

final userFuturedata = ReactiveProvider.createAsync<Map<String, dynamic>>(
  'user_profile',
  () async {
    await Future.delayed(Duration(seconds: 2));
    return {'name': 'Someone', 'level': 'Nerd'};
  },
);


