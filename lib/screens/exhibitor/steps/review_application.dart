import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/db_service.dart';
import '../../../models/booth.dart';
import '../../../models/event_model.dart';

class ReviewApplication extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String boothId;
  final Map<String, dynamic> formData;
  final VoidCallback onBack;
  final Function(String appId, double totalAmount) onSubmit;

  const ReviewApplication({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.boothId,
    required this.formData,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<ReviewApplication> createState() => _ReviewApplicationState();
}

class _ReviewApplicationState extends State<ReviewApplication> {
  final DbService _dbService = DbService();
  late Future<List<dynamic>> _dataFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = Future.wait([
      _dbService.getBooth(widget.eventId, widget.boothId),
      _dbService.getEventData(widget.eventId),
    ]);
  }

  Future<void> _handleSubmission(double totalAmount, String boothNumber, String eventDate) async {
    setState(() => _isSubmitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String appId = await _dbService.submitApplication(
        userId: user.uid,
        eventName: widget.eventName,
        eventId: widget.eventId,
        boothId: widget.boothId,
        boothNumber: boothNumber,
        eventDate: eventDate,
        applicationData: widget.formData,
        totalAmount: totalAmount,
      );
      
      widget.onSubmit(appId, totalAmount);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _getDimensions(String size) {
    switch (size) {
      case 'Small': return '3m x 3m';
      case 'Medium': return '5m x 5m';
      case 'Large': return '8m x 8m';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("Data not found"));
        }

        final booth = snapshot.data![0] as Booth;
        final eventData = snapshot.data![1] as Map<String, dynamic>;
        final eventModel = EventModel.fromJson(eventData);

        // Calculate Totals
        double boothPrice = booth.price;
        double addonsTotal = 0.0;
        if (widget.formData['addons'] != null) {
          for (var addon in widget.formData['addons']) {
            addonsTotal += (addon['price'] as num).toDouble();
          }
        }
        double subtotal = boothPrice + addonsTotal;
        double tax = subtotal * 0.06; // Assuming 6% Tax
        double grandTotal = subtotal + tax;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Company Info
                    _buildSectionHeader("Company Info"),
                    _buildInfoCard([
                      _buildDetailRow("Company Name", widget.formData['details']?['companyName'] ?? '-'),
                      const SizedBox(height: 12),
                      _buildDetailRow("Company Description", widget.formData['details']?['description'] ?? '-'),
                    ]),

                    const SizedBox(height: 24),

                    // 2. Exhibit Profile
                    _buildSectionHeader("Exhibit Profile"),
                    _buildInfoCard([
                      Text(
                        widget.formData['details']?['exhibitProfile'] ?? 'No profile provided.',
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // 3. Selected Add-ons
                    if (widget.formData['addons'] != null && (widget.formData['addons'] as List).isNotEmpty) ...[
                      _buildSectionHeader("Selected Add-ons"),
                      _buildInfoCard(
                        (widget.formData['addons'] as List).map<Widget>((addon) {
                          final name = addon['name'] ?? 'Unknown';
                          final price = addon['price'] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 20, color: Colors.blue),
                                const SizedBox(width: 10),
                                Text("$name - RM $price", style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 3. Event Details
                    _buildSectionHeader("Event Details"),
                    _buildInfoCard([
                      _buildDetailRow("Event Name", eventModel.name),
                      const SizedBox(height: 12),
                      _buildDetailRow("Event Date", eventModel.date.isNotEmpty ? eventModel.date : "Date TBD"),
                      const SizedBox(height: 12),
                      _buildDetailRow("Selected Booth", "Booth ${booth.boothNumber} (${booth.size} • ${_getDimensions(booth.size)})", isHighlight: true),
                    ]),

                    const SizedBox(height: 24),

                    // 4. Payment Summary
                    const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildSummaryRow("Booth Price", boothPrice),
                            if (addonsTotal > 0) ...[
                              const SizedBox(height: 8),
                              _buildSummaryRow("Add-ons Total", addonsTotal),
                            ],
                            const SizedBox(height: 8),
                            _buildSummaryRow("Tax (6%)", tax),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text(
                                  "RM ${grandTotal.toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80), // Space for sticky button
                  ],
                ),
              ),
            ),
            
            // Sticky Bottom Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("BACK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _handleSubmission(grandTotal, booth.boothNumber, eventModel.date),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: _isSubmitting 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                        : const Text("SUBMIT & PAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value, 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? Colors.blue : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        Text("RM ${amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}