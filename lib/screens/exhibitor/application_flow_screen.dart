import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/types.dart';

// Import the step widgets
import 'steps/event_selection.dart';
import 'steps/booth_selection.dart';
import 'steps/application_form.dart';
import 'steps/review_application.dart';

class ApplicationFlowScreen extends StatefulWidget {
  const ApplicationFlowScreen({super.key});

  @override
  State<ApplicationFlowScreen> createState() => _ApplicationFlowScreenState();
}

class _ApplicationFlowScreenState extends State<ApplicationFlowScreen> {
  int _currentStep = 1;
  
  // State to hold data across steps
  Event? _selectedEvent;
  Booth? _selectedBooth;
  ApplicationFormData _formData = ApplicationFormData();

  void _nextStep() {
    setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      context.pop(); // Go back to dashboard if on Step 1
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _prevStep,
        ),
      ),
      body: Column(
        children: [
          // The Stepper Widget
          _buildStepper(),
          
          // The Active Step Content
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 1: return "Select Event";
      case 2: return "Choose Booth";
      case 3: return "Application Form";
      case 4: return "Review";
      default: return "Application";
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return EventSelection(
          onEventSelected: (event) {
            setState(() => _selectedEvent = event);
            _nextStep();
          },
        );
      case 2:
        return BoothSelection(
          onBoothSelected: (booth) {
            setState(() => _selectedBooth = booth as Booth?);
            _nextStep();
          },
          onBack: _prevStep,
        );
      case 3:
        // Ensure we have data before showing form
        if (_selectedEvent == null || _selectedBooth == null) return const Center(child: Text("Error: Missing Data"));
        
        return ApplicationForm(
          event: _selectedEvent!,
          booth: _selectedBooth!,
          onSubmit: (data) {
            setState(() => _formData = data);
            _nextStep();
          },
          onBack: _prevStep,
        );
      case 4:
         if (_selectedEvent == null || _selectedBooth == null) return const Center(child: Text("Error: Missing Data"));

        return ReviewApplication(
          event: _selectedEvent!,
          booth: _selectedBooth!,
          formData: _formData,
          onSubmit: () {
            // FINISH: Navigate back to dashboard or success screen
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application Submitted Successfully!")));
            context.go('/exhibitor'); 
          },
          onBack: _prevStep,
        );
      default:
        return const Center(child: Text("Unknown Step"));
    }
  }

  // Your Custom Stepper Widget
  Widget _buildStepper() {
    final steps = [
      {'number': '1', 'label': 'Event'},
      {'number': '2', 'label': 'Booth'},
      {'number': '3', 'label': 'Form'},
      {'number': '4', 'label': 'Review'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _stepItem(
              steps[i]['number']!, 
              steps[i]['label']!, 
              isActive: _currentStep == (i + 1),
              isCompleted: _currentStep > (i + 1)
            ),
            if (i < steps.length - 1) 
              Expanded(child: Container(height: 2, color: _currentStep > (i + 1) ? const Color(0xFF4A90E2) : Colors.grey[300])),
          ]
        ],
      ),
    );
  }

  Widget _stepItem(String number, String label, {required bool isActive, required bool isCompleted}) {
    Color color = (isActive || isCompleted) ? const Color(0xFF4A90E2) : Colors.grey[300]!;
    return Column(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}