// import 'package:flutter/material.dart';
// import 'package:popsicle/popsicle.dart';

import 'package:popsicle/popsicle.dart';

// class DrivingMiddleware extends PopsicleMiddleware<int> {
//   final BuildContext context;

//   DrivingMiddleware(this.context);

//   @override
//   int? transform(int current, int next) {
//     // Example: allow all values, but let hooks decide side-effects
//     return next;
//   }

//   @override
//   void onChanged(int prev, int next) {
//     if (next < 18) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Must be 18+")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ You can drive!")),
//       );
//     }
//   }
// }
