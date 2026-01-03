import 'package:flutter/material.dart';
import '../../../services/db_service.dart';

class PaymentStep extends StatefulWidget {
  final String applicationId;
  final double amount;
  final VoidCallback onPaymentSuccess;

  const PaymentStep({
    super.key,
    required this.applicationId,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  final DbService _dbService = DbService();
  bool _isProcessing = false;
  String _selectedMethod = 'Credit Card';

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate network delay for payment processing
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Update application status to 'Paid'
      await _dbService.markApplicationAsPaid(widget.applicationId);
      widget.onPaymentSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Payment Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // Amount Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              // ignore: deprecated_member_use
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Payable", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text("RM ${widget.amount.toStringAsFixed(2)}", 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Text("Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _buildPaymentMethodTile("Credit Card", Icons.credit_card),
          _buildPaymentMethodTile("Online Banking", Icons.account_balance),
          _buildPaymentMethodTile("E-Wallet", Icons.account_balance_wallet),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isProcessing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("PAY NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(String title, IconData icon) {
    bool isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
          // ignore: deprecated_member_use
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}