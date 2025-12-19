import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // This works now!
import 'package:project3_lab04_nurlisa_52215124595/services/db_service.dart';
import '../../utils/app_theme.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _boothCountController = TextEditingController(text: "10"); 
  
  // URL Input for the Floor Plan
  final _imageUrlController = TextEditingController(text: "https://via.placeholder.com/800x600.png?text=Floor+Plan");
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final DbService _dbService = DbService();

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

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select dates")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create Event
      int eventId = await _dbService.createEvent(
        name: _nameController.text,
        location: _locationController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        floorPlanUrl: _imageUrlController.text.trim(),
      );

      // 2. Generate Booths
      int count = int.parse(_boothCountController.text);
      await _dbService.generateBooths(eventId, count);

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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Event Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(true),
                      child: Text(_startDate == null ? "Start Date" : DateFormat('yyyy-MM-dd').format(_startDate!)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(false),
                      child: Text(_endDate == null ? "End Date" : DateFormat('yyyy-MM-dd').format(_endDate!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _boothCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Number of Booths", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

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