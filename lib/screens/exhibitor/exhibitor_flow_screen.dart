import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/db_service.dart';
import '../../models/booth.dart';
import 'steps/booth_selection.dart';
import 'steps/application_form.dart';

class ApplicationFlowScreen extends StatefulWidget {
  final String? eventId;

  const ApplicationFlowScreen({super.key, this.eventId});

  @override
  State<ApplicationFlowScreen> createState() => _ApplicationFlowScreenState();
}

class _ApplicationFlowScreenState extends State<ApplicationFlowScreen> {
  int _currentStep = 0;
  late String _eventId;
  String _eventName = "Loading...";
  Booth? _selectedBooth;
  final DbService _dbService = DbService();

  @override
  void initState() {
    super.initState();
    _eventId = widget.eventId ?? '';
    if (_eventId.isNotEmpty) {
      _fetchEventDetails();
    }
  }

  Future<void> _fetchEventDetails() async {
    try {
      final eventData = await _dbService.getEventData(_eventId);
      if (mounted) {
        setState(() {
          _eventName = eventData['name'] ?? 'Unknown Event';
        });
      }
    } catch (e) {
      debugPrint("Error fetching event details: $e");
    }
  }

  void _onBoothSelected(Booth booth) {
    setState(() {
      _selectedBooth = booth;
      _currentStep = 1;
    });
  }

  void _onFormSubmitted(Map<String, dynamic> formData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _selectedBooth != null) {
      try {
        // Calculate total amount including addons
        double total = _selectedBooth!.price;
        final addons = formData['addons'] as List<dynamic>? ?? [];
        for (var addon in addons) {
          total += (addon['price'] as num).toDouble();
        }

        await _dbService.submitApplication(
          userId: user.uid,
          eventName: _eventName,
          eventId: _eventId,
          boothId: _selectedBooth!.id,
          boothNumber: _selectedBooth!.boothNumber,
          eventDate: "Upcoming", 
          applicationData: formData,
          totalAmount: total,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application Submitted Successfully!")));
          context.go('/exhibitor/my-applications');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_eventId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("No Event ID provided. Please select an event first.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_currentStep == 0 ? "Step 1: Select Booth" : "Step 2: Application Form")),
      body: _currentStep == 0
          ? BoothSelection(
              eventId: _eventId,
              onBoothSelected: _onBoothSelected,
              onBack: () => context.pop(),
            )
          : ApplicationForm(
              onBack: () => setState(() => _currentStep = 0),
              onFormSubmitted: _onFormSubmitted,
            ),
    );
  }
}