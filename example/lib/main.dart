import 'package:flutter/material.dart';
import 'package:respectlytics_flutter/respectlytics_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Respectlytics SDK
  await Respectlytics.configure(apiKey: 'your-api-key-here');

  // For self-hosted servers, pass baseUrl:
  // await Respectlytics.configure(
  //   apiKey: 'your-api-key-here',
  //   baseUrl: 'https://your-server.com/api/v1',
  // );

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
    Respectlytics.track('home_screen_view');

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
                await Respectlytics.track('button_tap');
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
          ],
        ),
      ),
    );
  }
}
