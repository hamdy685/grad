import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class PreviewScreen extends StatefulWidget {
  final XFile imageFile;
  const PreviewScreen({super.key, required this.imageFile});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isAnalyzing = false;
  final ApiService _apiService = ApiService();

  Future<void> _analyze() async {
    setState(() => _isAnalyzing = true);
    try {
      final result = await _apiService.analyzeImage(widget.imageFile);
      if (result != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: result, originalImage: widget.imageFile),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        bool isTimeout = e.toString().contains('TimeoutException');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isTimeout ? 'Request timed out' : 'Error: $e'),
            action: isTimeout ? SnackBarAction(label: 'Retry', onPressed: _analyze) : null,
          ),
        );
      }
    }
    if (mounted) {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Image')),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FutureBuilder<Uint8List>(
                  future: widget.imageFile.readAsBytes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9800)));
                    }
                    return Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)],
                        image: DecorationImage(
                          image: MemoryImage(snapshot.data!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _analyze,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analyze Image', style: TextStyle(fontSize: 18)),
                  ),
                ),
              )
            ],
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF9800)),
                    SizedBox(height: 24),
                    Text('Analyzing...', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
