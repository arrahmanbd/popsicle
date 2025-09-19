import 'package:example/logic/counter_logic.dart';
import 'package:example/logic/totdo_fetch.dart';
import 'package:example/popsicle.dart';
import 'package:example/ui/driving.dart';
import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

/// -----------------------------
/// Main App
/// -----------------------------
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Popsicle.bootStrap(popsicle);
  } catch (e, st) {
    debugPrint('Bootstrap error: $e\n$st');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Popsicle Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DemoHomePage(),
    );
  }
}

/// -----------------------------
/// DemoHomePage
/// -----------------------------
class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 3️⃣ Get the logic instance
    final counter = Popsicle.get<CounterLogic>();
    final todo = Popsicle.get<TodoState>();
    // 4️⃣ Add per-instance middleware
    counter.use((current, next) {
      print('CounterLogic changed: $current. -> $next');
      if (next > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Counter exceeded 5!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return next;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Popsicle Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.car_crash),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Driving()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 5️⃣ Observe the counter state
              PopsicleObserver<int>(
                state: counter,
                builder: (ctx, value) =>
                    Text('Counter: $value', style: const TextStyle(fontSize: 28)),
              ),
          
              const SizedBox(height: 32),
          
              // 6️⃣ Increment Button
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Increment'),
                onPressed: () => counter.increment(),
              ),
          
              const SizedBox(height: 16),
          
              // 7️⃣ Decrement Button
              ElevatedButton.icon(
                icon: const Icon(Icons.remove),
                label: const Text('Decrement'),
                onPressed: () => counter.decrement(),
              ),
          
              const SizedBox(height: 32),
          
              // 8️⃣ Read-only observer
              PopsicleObserver<int>(
                state: counter,
                builder: (ctx, value) => Text(
                  'Readonly: $value',
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ),
          
              const SizedBox(height: 32),
          
              // 9️⃣ Using alias: lick
              counter.view((value) => Text('Alias lick: $value')),
          
              //async
              PopsicleObserver<AppState<List<Todo>>>(
                state: todo,
                builder: (context, state) {
                  if (state is AppLoading)
                    return const CircularProgressIndicator();
                  if (state is AppFailure) return Text('Error: ${state}');
                  if (state is AppSuccess<List<Todo>>) {
                    final todos = state.data;
                    return ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (_, index) {
                        final todo = todos[index];
                        return ListTile(
                          title: Text(todo.todo),
                          trailing: Icon(
                            todo.completed
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
