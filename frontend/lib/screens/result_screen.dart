import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final XFile originalImage;

  const ResultScreen({super.key, required this.result, required this.originalImage});

  @override
  Widget build(BuildContext context) {
    bool isFresh = result['quality'].toString().toLowerCase() == 'fresh';
    Color qualityColor = isFresh ? const Color(0xFF4CAF50) : const Color(0xFFEF4444); // Green/Red
    
    // Decode base64 mask
    final imageBytes = result['mask_bytes'] ?? Uint8List(0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 16),
                // Images (Original vs Mask)
                SizedBox(
                  height: 250,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      FutureBuilder<Uint8List>(
                        future: originalImage.readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 200, 
                              height: 200, 
                              child: Center(child: CircularProgressIndicator())
                            );
                          }
                          return _buildImageCard(MemoryImage(snapshot.data!), 'Original');
                        }
                      ),
                      const SizedBox(width: 16),
                      _buildImageCard(MemoryImage(imageBytes as Uint8List), 'AI Segmentation'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Name Header
                Text(
                  result['fruit_name'].toString().toUpperCase(),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900, 
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildGlassCard(
                        context,
                        'Quality',
                        result['quality'].toString().toUpperCase(),
                        isFresh ? Icons.eco_rounded : Icons.coronavirus_rounded,
                        qualityColor,
                      ),
                      const SizedBox(height: 16),
                      _buildGlassCard(
                        context,
                        'Estimated Size',
                        '${result['size_cm']} cm²',
                        Icons.straighten_rounded,
                        const Color(0xFF3B82F6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(ImageProvider image, String label) {
    return Column(
      children: [
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4), 
                blurRadius: 15, 
                offset: const Offset(0, 8)
              )
            ],
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(), 
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildGlassCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15), 
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400], letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
