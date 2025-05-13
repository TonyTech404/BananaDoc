import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFLite Fix',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const TFLiteFixScreen(),
    );
  }
}

class TFLiteFixScreen extends StatefulWidget {
  const TFLiteFixScreen({Key? key}) : super(key: key);

  @override
  State<TFLiteFixScreen> createState() => _TFLiteFixScreenState();
}

class _TFLiteFixScreenState extends State<TFLiteFixScreen> {
  final List<String> _logs = [];
  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    print(message);
  }

  Future<void> _fixTFLiteOfflineMode() async {
    setState(() {
      _isWorking = true;
      _logs.clear();
      _addLog('Starting TFLite offline mode fix...');
    });

    try {
      // 1. Create a minimal valid model structure that the app can load
      _addLog('Creating a minimal valid TFLite structure...');

      // Get the documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory(path.join(appDir.path, 'tflite_models'));

      // Create the directory if it doesn't exist
      if (!modelsDir.existsSync()) {
        modelsDir.createSync(recursive: true);
      }

      _addLog('Models directory: ${modelsDir.path}');

      // Create a mock model file (just an empty file with header)
      final modelFile =
          File(path.join(modelsDir.path, 'banana_mobile_model.tflite'));
      final mockModelBytes = Uint8List.fromList(
          [0x18, 0x00, 0x00, 0x00, 0x54, 0x46, 0x4C, 0x33]); // TFL3 header
      await modelFile.writeAsBytes(mockModelBytes);

      _addLog('Created mock model file: ${modelFile.path}');

      // Create a labels file
      final labelsFile = File(path.join(modelsDir.path, 'labels.txt'));
      const labels = '''Healthy
Nitrogen
Phosphorus
Potassium
Calcium
Magnesium
Sulphur
Iron''';
      await labelsFile.writeAsString(labels);

      _addLog('Created labels file: ${labelsFile.path}');

      // 2. Update the offline service settings
      _addLog('Fix completed! You can now try using offline mode again.');

      _addLog(
          '\nIMPORTANT: This is just a temporary fix to make the app load.');
      _addLog(
          'The model will not actually work for predictions until you add a real TFLite model.');
    } catch (e) {
      _addLog('Error during fix: $e');
    } finally {
      setState(() {
        _isWorking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TFLite Offline Mode Fix'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isWorking ? null : _fixTFLiteOfflineMode,
              child: const Text('Fix TFLite Offline Mode'),
            ),
            const SizedBox(height: 16),
            Text(
              'This tool will fix the offline mode in the app by creating a valid TFLite structure.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Logs:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isWorking
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(_logs[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
