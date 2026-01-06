import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
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

  // --- PAYMENT LOGIC ---
  Future<void> _processPayment() async {
    // 1. Hide keyboard
    FocusScope.of(context).unfocus();

    // 2. Check Validation
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      // VISUAL FEEDBACK: Shows a red bar if the form is wrong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix the red errors on the form!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return; 
    }

    // 3. Start Loading
    setState(() => _isLoading = true);

    try {
      // Simulate network delay (2 seconds)
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
            "Your booth has been reserved!\nCheck 'My Applications'.", 
            textAlign: TextAlign.center
          ),
          actions: [
  TextButton(
    onPressed: () {
      Navigator.pop(ctx); // Close Dialog
      Navigator.pop(context); // Close Payment Screen & Go back to Flow
    },
    child: const Text("View Receipt"),
  )
],
        ),
      );

    } catch (e) {
      // 5. Error Handling
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Secure Payment")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Header
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
                
                // Card Number Field
                TextFormField(
                  controller: _cardController,
                  decoration: const InputDecoration(
                    labelText: "Card Number",
                    hintText: "0000 0000 0000 0000",
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  // Ensure only numbers are typed
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 16, 
                  validator: (value) {
                    if (value == null || value.length < 16) {
                      return "Enter a valid 16-digit card number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    // Expiry Field
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: const InputDecoration(
                          labelText: "Expiry (MM/YY)", 
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                           if (value == null || value.isEmpty) return "Required";
                           return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // CVV Field
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(
                          labelText: "CVV", 
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.security),
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 3,
                        validator: (val) => (val != null && val.length == 3) ? null : "Invalid CVV",
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 50), 
                
                ElevatedButton(
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
      ),
    );
  }
}