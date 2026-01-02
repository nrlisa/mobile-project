import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';
import '../../widgets/progress_stepper.dart'; 
import 'steps/booth_selection.dart'; // Import your booth selection widget
import 'steps/application_form.dart'; // Import for step 3
import 'steps/review_application.dart'; // Import for step 4

class ApplicationFlowScreen extends StatefulWidget {
  const ApplicationFlowScreen({super.key});

  @override
  State<ApplicationFlowScreen> createState() => _ApplicationFlowScreenState();
}

class _ApplicationFlowScreenState extends State<ApplicationFlowScreen> {
  final DbService _dbService = DbService();
  late Future<List<Map<String, dynamic>>> _eventsFuture;
  
  // State variables to hold user selections
  String? _selectedEventId;
  String? _selectedBoothId;
  Map<String, dynamic>? _applicationData;

  int _currentStep = 0; 

  @override
  void initState() {
    super.initState();
    _eventsFuture = _dbService.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Dynamic Title
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 1. Top Stepper
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ProgressStepper(currentStep: _currentStep),
          ),

          // 2. Dynamic Body Content based on _currentStep
          Expanded(
            child: _buildCurrentStepContent(),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 0: return "Select Event";
      case 1: return "Select Booth";
      case 2: return "Application Form";
      case 3: return "Review & Submit";
      default: return "Application Flow";
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildEventSelectionStep();
      case 1:
        return BoothSelection(
          onBack: () => setState(() => _currentStep = 0),
          onBoothSelected: (booth) {
            setState(() {
              _selectedBoothId = booth.id;
              _currentStep = 2; // Move to Application Form (Step 3)
            });
          }, eventId: _selectedEventId ?? '',
        );
      case 2:
        return ApplicationForm(
          onBack: () => setState(() => _currentStep = 1),
          onFormSubmitted: (data) {
            setState(() {
              _applicationData = data;
              _currentStep = 3; // Move to Review
            });
          },
        );
      case 3:
        return ReviewApplication(
          boothId: _selectedBoothId ?? '',
          formData: _applicationData ?? {},
          onBack: () => setState(() => _currentStep = 2),
          onSubmit: () {
            // Final submission logic here
            context.go('/exhibitor');
          },
        );
      default:
        return const Center(child: Text("Error: Step not found"));
    }
  }

  Widget _buildEventSelectionStep() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search event...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Event List from Database
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No events available."));
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  var event = snapshot.data![index];
                  bool isSelected = _selectedEventId == event['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEventId = event['id'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.event, color: Colors.black),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['name'] ?? 'Event Name',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  event['location'] ?? 'Location',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Navigation Buttons for Step 0
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("BACK", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: _selectedEventId == null 
                  ? null 
                  : () {
                    setState(() {
                      _currentStep = 1; // Move to Booth Selection
                    });
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: const Text("NEXT"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}