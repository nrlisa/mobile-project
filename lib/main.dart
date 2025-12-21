import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project3_lab04_nurlisa_52215124595/screens/exhibitor/application_flow_screen.dart';
import 'package:project3_lab04_nurlisa_52215124595/screens/exhibitor/steps/booth_selection.dart';
import 'package:project3_lab04_nurlisa_52215124595/screens/exhibitor/steps/review_application.dart';
import '../../models/types.dart';
import 'screens/exhibitor/steps/event_selection.dart';

class ApplicationFlowScreen extends StatefulWidget {
  const ApplicationFlowScreen({super.key});

  @override
  State<ApplicationFlowScreen> createState() => _ApplicationFlowScreenState();
}

class _ApplicationFlowScreenState extends State<ApplicationFlowScreen> {
  int _currentStep = 1;
  Event? _selectedEvent;
  Booth? _selectedBooth;
  Map<String, dynamic> _applicationData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 1: return "Select Exhibition";
      case 2: return "Select Booth";
      case 3: return "Application Form";
      case 4: return "Review & Submit";
      default: return "Booking";
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return EventSelection(onEventSelected: (ev) {
          setState(() {
            _selectedEvent = ev;
            _currentStep = 2;
          });
        });
      case 2:
        return BoothSelection(
          eventId: _selectedEvent?.id ?? '',
          onBack: () => setState(() => _currentStep = 1),
          onBoothSelected: (b) {
            setState(() {
              _selectedBooth = b as Booth?;
              _currentStep = 3;
            });
          },
        );
      case 3:
        return ApplicationForm(
          event: _selectedEvent!,
          booth: _selectedBooth!,
          onBack: () => setState(() => _currentStep = 2),
          onFormSubmitted: (data) {
            setState(() {
              _applicationData = data;
              _currentStep = 4;
            });
          },
        );
      case 4:
        return ReviewApplication(
          event: _selectedEvent!,
          booth: _selectedBooth!,
          boothId: _selectedBooth?.id ?? '',
          formData: _applicationData,
          onBack: () => setState(() => _currentStep = 3),
          onSubmit: () => context.go('/exhibitor'),
        );
      default:
        return const Center(child: Text("Error"));
    }
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentStep > i ? Colors.blue : Colors.grey[300],
          ),
        )),
      ),
    );
  }
}