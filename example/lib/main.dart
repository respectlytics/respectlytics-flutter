import 'package:flutter/material.dart';
import 'package:respectlytics_flutter/respectlytics_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure Respectlytics SDK
  await Respectlytics.configure(apiKey: 'your-api-key-here');
  
  // Enable user tracking (optional)
  await Respectlytics.identify();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Respectlytics Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Track screen view
    Respectlytics.track('screen_view', screen: 'HomeScreen');
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Respectlytics Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Privacy-first analytics'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Respectlytics.track('button_tap', screen: 'HomeScreen');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event tracked!')),
                  );
                }
              },
              child: const Text('Track Event'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await Respectlytics.flush();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Events flushed!')),
                  );
                }
              },
              child: const Text('Force Flush'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await Respectlytics.reset();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User reset!')),
                  );
                }
              },
              child: const Text('Reset User'),
            ),
          ],
        ),
      ),
    );
  }
}
