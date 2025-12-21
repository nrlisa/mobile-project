import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/types.dart';
import '../../services/db_service.dart'; // Ensure this import is correct
import 'steps/event_selection.dart';
import 'steps/booth_selection.dart';
import 'steps/application_form.dart';
import 'steps/review_application.dart';
import 'steps/dummy_payment_page.dart';

class ApplicationFlowScreen extends StatefulWidget {
  const ApplicationFlowScreen({super.key});

  @override
  State<ApplicationFlowScreen> createState() => _ApplicationFlowScreenState();
}

class _ApplicationFlowScreenState extends State<ApplicationFlowScreen> {
  int _currentStep = 1;
  Booth? _selectedBooth;
  Map<String, dynamic> _applicationData = {};
  Event? _selectedEvent;
  
  // Initialize DbService
  final DbService _dbService = DbService(); 

  double _calculateGrandTotal() {
    double boothPrice = _selectedBooth?.price ?? 0.0;
    final addons = _applicationData['addons'] as List<dynamic>? ?? [];
    
    // Using previousValue to avoid linting naming conflicts
    double addonsTotal = addons.fold(0.0, (previousValue, item) => previousValue + (item['price'] ?? 0.0));    
    
    double subtotal = boothPrice + addonsTotal;
    double tax = subtotal * 0.06; // 6% Tax
    return subtotal + tax;
  }

  // UPDATED: Now uses DbService for centralized database logic
  Future<void> _saveApplicationToDatabase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _dbService.submitApplication(
        userId: user.uid,
        eventName: _selectedEvent?.name ?? 'Unknown Event',
        boothId: _selectedBooth?.id ?? 'N/A',
        applicationData: _applicationData,
        totalAmount: _calculateGrandTotal(),
      );
    } catch (e) {
      debugPrint("❌ Error saving application via DbService: $e");
    }
  }

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
          const Divider(height: 1),
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
          onBack: () => setState(() => _currentStep = 1),
          onBoothSelected: (id) {
            setState(() {
              _selectedBooth = Booth(
                id: id,
                hall: id.startsWith('A') ? 'Hall A' : 'Hall B',
                type: 'Standard',
                status: 'selected',
                price: id.startsWith('A') ? 1000.0 : 2500.0,
              );
              _currentStep = 3;
            });
          },
        );
      case 3:
        return ApplicationForm(
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
          selectedEvent: _selectedEvent,
          boothId: _selectedBooth?.id ?? '',
          formData: _applicationData,
          onBack: () => setState(() => _currentStep = 3),
          onSubmit: () => _navigateToPayment(),
        );
      default:
        return const Center(child: Text("Error"));
    }
  }

  void _navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DummyPaymentPage(
          amount: _calculateGrandTotal(),
          onPaymentSuccess: () async {
            // Wait for DB save to finish
            await _saveApplicationToDatabase(); 
            
            if (mounted) {
              // Standard hyphenated path to avoid 404
              // ignore: use_build_context_synchronously
              context.go('/exhibitor/my-applications'); 
            }
          },
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final List<String> stepTitles = ['Select Event', 'Choose Booth', 'Application Form', 'Review & Submit'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stepTitles.length, (index) {
          int stepNum = index + 1;
          bool isCompleted = stepNum < _currentStep;
          bool isCurrent = stepNum == _currentStep;
          Color color = (isCompleted || isCurrent) ? Colors.blue : Colors.grey[300]!;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Container(height: 2, color: index == 0 ? Colors.transparent : (stepNum <= _currentStep ? Colors.blue : Colors.grey[300]))),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1)] : null,
                      ),
                      child: Center(
                        child: isCompleted 
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text("$stepNum", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    Expanded(child: Container(height: 2, color: index == stepTitles.length - 1 ? Colors.transparent : (stepNum < _currentStep ? Colors.blue : Colors.grey[300]))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stepTitles[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? Colors.black : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}