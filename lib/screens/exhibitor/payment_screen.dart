import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for input formatters
import 'package:go_router/go_router.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    // 1. Clear keyboard to see any error messages clearly
    FocusScope.of(context).unfocus();

    // 2. Check Validation
    if (!_formKey.currentState!.validate()) {
      // Logic Fix: If validation fails, stop here so the user sees the red error text.
      // We explicitly return so logic doesn't continue.
      return; 
    }

    // 3. Start Loading
    setState(() => _isLoading = true);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 4. Success Logic
      setState(() => _isLoading = false);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text("Payment Successful"),
            ],
          ),
          content: const Text(
            "Your booth has been successfully reserved.\nYou can view it in 'My Applications'.", 
            textAlign: TextAlign.center
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Ensure the dialog closes before navigating
                context.pop(); 
                // Navigate away - ensure this route exists in your GoRouter config
                context.go('/exhibitor/applications'); 
              },
              child: const Text("View Receipt"),
            )
          ],
        ),
      );

    } catch (e) {
      // 5. Error Handling (Fixes the "Stuck Loading" issue)
      // If payment fails, we MUST turn off loading
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Secure Payment")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(child: Text("All transactions are secure and encrypted.")),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text("Card Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Card Number
              TextFormField(
                controller: _cardController,
                decoration: const InputDecoration(
                  labelText: "Card Number",
                  hintText: "0000 0000 0000 0000",
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                  counterText: "", // Hides the character counter
                ),
                keyboardType: TextInputType.number,
                maxLength: 16, // Hard limit
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                ],
                validator: (value) {
                  if (value == null || value.length < 16) {
                    return "Enter a full 16-digit card number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  // Expiry Date
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: "Expiry (MM/YY)", 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: "MM/YY"
                      ),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required";
                        }
                        return null; // Add logic here if you want strict date checking
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // CVV
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: "CVV", 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                        counterText: "",
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 3, // Hard limit
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (val) => (val != null && val.length == 3) ? null : "Invalid CVV",
                    ),
                  ),
                ],
              ),
              const Spacer(),
              
              ElevatedButton(
                // Logic Fix: Ensure button is disabled ONLY when loading
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white)) 
                  : const Text("Pay RM 1,000.00", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}