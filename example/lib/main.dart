import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

// ==============================
// Counter Logic
// ==============================
class CounterLogic extends PopsicleState<int> {
  CounterLogic() : super(state: 0);
  void increment() => shift(state + 1);
  void decrement() => shift(state - 1);
}

// ==============================
// Driving Info Model
// ==============================
class DrivingInfo {
  final int age;
  final bool canDrive;

  DrivingInfo({required this.age, required this.canDrive});

  DrivingInfo copyWith({int? age, bool? canDrive}) {
    return DrivingInfo(
      age: age ?? this.age,
      canDrive: canDrive ?? this.canDrive,
    );
  }
}

// ==============================
// Driving Logic
// ==============================
class DrivingLogic extends PopsicleState<DrivingInfo> {
  DrivingLogic() : super(state: DrivingInfo(age: 0, canDrive: false));

  BuildContext? _context;

  void bindContext(BuildContext context) => _context = context;

  // Middleware: UI feedback for under 18
  void initMiddleware() {
    use((current, next) {
      if (next.age < 0) return current.copyWith(age: 0);

      if (next.age < 18 && _context != null) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          const SnackBar(
            content: Text('🚫 You must be 18 or older to drive!'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      return next.copyWith(canDrive: next.age >= 18);
    });
  }
}

// ==============================
// Demo App
// ==============================
void main() {
  runApp(const MaterialApp(home: DemoHomePage()));
}

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popsicle Demo')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ==============================
            // Counter Section
            // ==============================
            LogicProvider<int, CounterLogic>(
              create: () => CounterLogic(),
              builder: (context, counterLogic) {
                return Column(
                  children: [
                    PopWidget<int, CounterLogic>(
                      create: () => counterLogic,
                      builder: (context, value, logic) => Text(
                        'Counter: $value',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: counterLogic.increment,
                          child: const Text('Increment'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: counterLogic.decrement,
                          child: const Text('Decrement'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // ==============================
            // Navigate to Driving Page
            // ==============================
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Check Driving Eligibility'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DrivingPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================
// Driving Page
// ==============================
class DrivingPage extends StatelessWidget {

  DrivingPage({super.key});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LogicProvider<DrivingInfo, DrivingLogic>(
      create: () {
        final logic = DrivingLogic();
        logic.bindContext(context);
        logic.initMiddleware();
        // Initialize with counter value
        logic.shift(logic.state.copyWith(age:0));
        return logic;
      },
      builder: (context, drivingLogic) {
        controller.text = drivingLogic.state.age.toString();
        return Scaffold(
          appBar: AppBar(title: const Text('Driving Eligibility Checker')),
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
                      final ageValue = int.tryParse(value);
                      if (ageValue != null) {
                        final current = drivingLogic.state;
                        drivingLogic.shift(current.copyWith(age: ageValue));
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  PopWidget<DrivingInfo, DrivingLogic>(
                    create: () => drivingLogic,
                    builder: (context, info, logic) {
                      return Text(
                        info.canDrive
                            ? '🚗 You can drive!'
                            : '🚫 Not eligible to drive.',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: info.canDrive ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
