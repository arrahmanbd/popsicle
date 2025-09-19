import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

class DrivingLogic {
  final age = PopsicleState<int>(state: 0);
  final canDrive = PopsicleState<bool>(state: false);

  DrivingLogic() {
    // Entangle age updates with eligibility logic
    age.entangle(age, (box) {
      final years = box.state;
      canDrive.shift(years >= 18);
    });
  }

  void dispose() {
    age.collapse();
    canDrive.collapse();
  }
}

class DrivingPage extends StatefulWidget {
  const DrivingPage({super.key});

  @override
  State<DrivingPage> createState() => _DrivingPageState();
}

class _DrivingPageState extends State<DrivingPage> {
  final logic = DrivingLogic();
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter your age',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final age = int.tryParse(value);
                  if (age != null) {
                    logic.age.shift(age);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Observe if they can drive
              logic.canDrive.view(
                (canDrive) => Text(
                  canDrive == true
                      ? '🚗 You can drive!'
                      : '🚫 Not eligible to drive.',
                  style: TextStyle(
                    fontSize: 24,
                    color: canDrive == true ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
