import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic>? _history;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _apiService.getHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history == null || _history!.isEmpty) {
      return const Center(child: Text('No history found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history!.length,
      itemBuilder: (context, index) {
        final item = _history![index];
        final isFresh = item['quality'].toString().toLowerCase() == 'fresh';
        
        String base64String = item['image_mask'];
        if (base64String.contains(',')) {
          base64String = base64String.split(',')[1];
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(base64Decode(base64String), width: 70, height: 70, fit: BoxFit.cover),
              ),
            ),
            title: Text(item['fruit_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Quality: ${item['quality'].toString().toUpperCase()} • ${item['size_cm']} cm²', 
                          style: TextStyle(color: Colors.grey[400])),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isFresh ? const Color(0xFF4CAF50) : const Color(0xFFEF4444)).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFresh ? Icons.check_circle : Icons.dangerous,
                color: isFresh ? const Color(0xFF4CAF50) : const Color(0xFFEF4444),
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}
