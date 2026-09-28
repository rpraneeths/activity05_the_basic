import 'package:flutter/material.dart';

void main() => runApp(const CounterApp());

// BLOCK 2: App shell.
// The app shell does not store changing counter state,
// so it is a StatelessWidget.
class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Activity 05 Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const CounterPage(),
    );
  }
}

// BLOCK 3: Stateful screen.
// The counter changes after user interactions,
// so this screen must be stateful.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // BLOCK 4: State.
  int _counter = 40;
  int _increment = 7;

  final List<int> _history = [];

  final TextEditingController _incrementController =
      TextEditingController(text: '7');

  @override
  void dispose() {
    // The controller uses resources, so clean it up
    // when this screen is removed.
    _incrementController.dispose();
    super.dispose();
  }

  // Checks the allowed counter range.
  bool _isValidValue(int value) {
    return value >= 10 && value <= 150;
  }

  // Activity 05 color rule:
  // red at 10,
  // green above 90,
  // black otherwise.
  Color _counterColor() {
    if (_counter == 10) {
      return Colors.red;
    }

    if (_counter > 90) {
      return Colors.green;
    }

    return Colors.black;
  }

  // Shows concise feedback to the user.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // Moves the counter only when the requested value
  // is inside the allowed range.
  //
  // History is recorded only when the value actually changes.
  void _moveTo(int nextValue) {
    if (!_isValidValue(nextValue)) {
      if (nextValue < 10) {
        _showMessage('Minimum is 10. Counter was not changed.');
      } else {
        _showMessage('Maximum is 150. Counter was not changed.');
      }
      return;
    }

    if (nextValue == _counter) {
      _showMessage('Counter is already $nextValue.');
      return;
    }

    setState(() {
      _history.add(_counter);
      _counter = nextValue;
    });
  }

  // Accept positive whole-number increments only.
  void _readIncrement(String input) {
    final value = int.tryParse(input.trim());

    if (value == null || value <= 0) {
      _showMessage(
        'Enter a positive whole number, such as 5 or 10.',
      );
      return;
    }

    setState(() {
      _increment = value;
    });
  }

  // Restores the previous counter value.
  void _undo() {
    if (_history.isEmpty) {
      _showMessage('There is no earlier value to restore.');
      return;
    }

    setState(() {
      _counter = _history.removeLast();
    });
  }

  // Resets the counter to 10.
  // The reset itself becomes undoable when it changes the value.
  void _reset() {
    if (_counter == 10) {
      _showMessage('Counter is already at 10.');
      return;
    }

    _moveTo(10);
  }

  @override
  Widget build(BuildContext context) {
    // BLOCK 6: Build.
    // Build reads state and connects widgets to actions.
    final Color counterColor = _counterColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 05 Counter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current Value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              '$_counter',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(
                    color: counterColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Allowed range: 10–150',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            Text(
              'Move counter with slider',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            Slider(
              value: _counter.toDouble(),
              min: 10,
              max: 150,
              divisions: 140,
              label: '$_counter',
              onChanged: (value) {
                _moveTo(value.round());
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _incrementController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Increment amount',
                hintText: 'Positive whole number',
                border: OutlineInputBorder(),
              ),
              onChanged: _readIncrement,
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _moveTo(_counter - _increment);
                  },
                  icon: const Icon(Icons.remove),
                  label: Text('Decrease by $_increment'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _moveTo(_counter + _increment);
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Increase by $_increment'),
                ),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset to 10'),
                ),
                OutlinedButton.icon(
                  onPressed: _undo,
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'State',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('Current value: $_counter'),
                    Text('Increment: $_increment'),
                    Text(
                      _history.isEmpty
                          ? 'History: none'
                          : 'History: ${_history.join(', ')}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}