import 'package:example/logic/driving_logic.dart';
import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

class Driving extends StatefulWidget {
  const Driving({super.key});

  @override
  State<Driving> createState() => _DrivingState();
}

class _DrivingState extends State<Driving> {
  final controller = TextEditingController();
  final logic = Popsicle.get<DrivingLogic>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driving Test')),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            logic.view(
              (value) => Text(
                value,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 56),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Enter Your Age'),
            ),
            SizedBox(height: 45),
            ElevatedButton(
              onPressed: () {
                final age = int.tryParse(controller.text);
                logic.check(age ?? 0);
              },
              child: Text("Calculate"),
            ),
          ],
        ),
      ),
    );
  }
}
