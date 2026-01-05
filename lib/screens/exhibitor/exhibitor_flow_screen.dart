import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';
import '../../models/booth.dart';
import 'steps/booth_selection.dart';
import 'steps/application_form.dart';
import 'steps/review_application.dart';
import 'steps/payment_step.dart';
import '../../widgets/progress_stepper.dart';

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
  Map<String, dynamic> _formData = {};
  String? _applicationId;
  double _totalAmount = 0.0;

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

  void _onFormCompleted(Map<String, dynamic> formData) {
    setState(() {
      _formData = formData;
      _currentStep = 2; // Move to Review
    });
  }
  void _onReviewSubmitted(String appId, double totalAmount) {
    setState(() {
      _applicationId = appId;
      _totalAmount = totalAmount;
      _currentStep = 3; // Move to Payment
    });
  }

  void _onPaymentSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful! Application Submitted.")),
    );
    context.go('/exhibitor/my-applications');
  }

  @override
  Widget build(BuildContext context) {
    if (_eventId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("No Event ID provided. Please select an event first.")),
      );
    }

    String title;
    switch (_currentStep) {
      case 0: title = "Step 1: Select Booth"; break;
      case 1: title = "Step 2: Application Form"; break;
      case 2: title = "Step 3: Review Application"; break;
      case 3: title = "Step 4: Payment"; break;
      default: title = "Application";
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ProgressStepper(currentStep: _currentStep),
          const SizedBox(height: 16),
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return BoothSelection(
          eventId: _eventId,
          onBoothSelected: _onBoothSelected,
          onBack: () => context.pop(),
        );
      case 1:
        return ApplicationForm(
          onBack: () => setState(() => _currentStep = 0),
          onFormSubmitted: _onFormCompleted,
        );
      case 2:
        return ReviewApplication(
          eventId: _eventId,
          eventName: _eventName,
          boothId: _selectedBooth!.id,
          formData: _formData,
          onBack: () => setState(() => _currentStep = 1),
          onSubmit: _onReviewSubmitted,
        );
      case 3:
        return PaymentStep(
          applicationId: _applicationId!,
          amount: _totalAmount,
          onPaymentSuccess: _onPaymentSuccess,
        );
      default:
        return const Center(child: Text("Unknown Step"));
    }
  }
}