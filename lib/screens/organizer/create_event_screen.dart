import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// REMOVED: import 'package:intl/intl.dart'; 
import '../../services/db_service.dart'; 
import '../../utils/app_theme.dart';
import '../../services/auth_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _boothCountController = TextEditingController(text: "10"); 
  final _imageUrlController = TextEditingController(text: "https://via.placeholder.com/800x600.png?text=Floor+Plan");
  
  // State variables
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  // Service
  final DbService _dbService = DbService();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _boothCountController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Helper method to format date without intl package
  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T')[0]; // Returns YYYY-MM-DD
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select dates")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? organizerId = await _authService.getCurrentSpecificId();
      organizerId ??= _authService.currentUser?.uid;
      if (organizerId == null) throw Exception("User not logged in");

      // 1. Create Event (Returns String ID from Firebase)
      String eventId = await _dbService.createEvent(
        name: _nameController.text,
        location: _locationController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        floorPlanUrl: _imageUrlController.text.trim(),
        organizerId: organizerId,
      );

      // 2. Generate Booths
      int count = int.tryParse(_boothCountController.text) ?? 0;
      if (count > 0) {
        await _dbService.generateBooths(eventId, count);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event Created!")));
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Event")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Event Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(true),
                      // CHANGED: Use _formatDate helper instead of DateFormat
                      child: Text(_startDate == null ? "Start Date" : _formatDate(_startDate!)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(false),
                      // CHANGED: Use _formatDate helper instead of DateFormat
                      child: Text(_endDate == null ? "End Date" : _formatDate(_endDate!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Booth Count
              TextFormField(
                controller: _boothCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Number of Booths", border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  if (int.tryParse(v) == null) return "Must be a number";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: "Floor Plan Image URL",
                  border: OutlineInputBorder(),
                  hintText: "Paste image link here",
                ),
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 10),

              // Image Preview
              Container(
                height: 150,
                color: Colors.grey[200],
                child: _imageUrlController.text.isNotEmpty
                    ? Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      )
                    : const Center(child: Text("Image Preview")),
              ),

              const SizedBox(height: 24),

              // Submit Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("PUBLISH EVENT", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}