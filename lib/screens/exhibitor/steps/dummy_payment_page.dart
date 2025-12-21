import 'package:flutter/material.dart';

class DummyPaymentPage extends StatelessWidget {
  final double amount;
  final VoidCallback onPaymentSuccess;

  const DummyPaymentPage({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Secure Checkout"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Total Payable Amount", style: TextStyle(color: Colors.grey)),
            Text(
              "RM ${amount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            _buildTextField("Cardholder Name", Icons.person, "John Doe"),
            const SizedBox(height: 20),
            _buildTextField("Card Number", Icons.credit_card, "XXXX XXXX XXXX XXXX"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTextField("Expiry Date", Icons.date_range, "MM/YY")),
                const SizedBox(width: 20),
                Expanded(child: _buildTextField("CVV", Icons.lock, "***", obscure: true)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _processPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("CONFIRM & PAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, String hint, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    // 
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate dummy processing time
    Future.delayed(const Duration(seconds: 2), () {
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Close loading dialog
      // ignore: use_build_context_synchronously
      _showSuccess(context);
    });
  }

  void _showSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 80),
        content: const Text(
          "Payment Successful!\nYour application has been submitted to the organizer.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: onPaymentSuccess,
            child: const Center(child: Text("VIEW MY APPLICATIONS")),
          ),
        ],
      ),
    );
  }
}