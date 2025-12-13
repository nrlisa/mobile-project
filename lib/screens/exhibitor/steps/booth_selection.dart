import 'package:flutter/material.dart';
import 'package:project3_lab04_nurlisa_52215124595/components/booth_card.dart';
import '../../../models/types.dart'; // Correct Data Model
// Correct Component Link

class BoothSelection extends StatefulWidget {
  final Function(Booth) onBoothSelected;
  final VoidCallback onBack;

  const BoothSelection({
    super.key,
    required this.onBoothSelected,
    required this.onBack,
  });

  @override
  State<BoothSelection> createState() => _BoothSelectionState();
}

class _BoothSelectionState extends State<BoothSelection> {
  String? selectedBoothId;
  bool showModal = false;
  String searchQuery = '';

  // Mock Data
  final List<Booth> mockBooths = [
    Booth(id: 'A-01', price: 1000, status: 'available', hall: 'Hall A', type: 'Small', dimensions: '7.0m x 7.0m'),
    Booth(id: 'A-02', price: 1000, status: 'booked', hall: 'Hall A', type: 'Small'),
    Booth(id: 'A-03', price: 1000, status: 'booked', hall: 'Hall A', type: 'Small'),
    Booth(id: 'A-04', price: 1000, status: 'reserved', hall: 'Hall A', type: 'Small'),
    Booth(id: 'B-01', price: 2500, status: 'available', hall: 'Hall B', type: 'Medium', dimensions: '10.0m x 10.0m'),
    Booth(id: 'B-02', price: 2500, status: 'reserved', hall: 'Hall B', type: 'Medium'),
    Booth(id: 'B-03', price: 2500, status: 'available', hall: 'Hall B', type: 'Medium', dimensions: '10.0m x 10.0m'),
  ];

  void handleBoothTap(Booth booth) {
    if (booth.status == 'available') {
      setState(() {
        selectedBoothId = booth.id;
        showModal = true;
      });
    }
  }

  Booth? getSelectedBooth() {
    try {
      return mockBooths.firstWhere((b) => b.id == selectedBoothId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooths = mockBooths.where((b) =>
        b.id.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    final halls = ['Hall A', 'Hall B'];
    final booth = getSelectedBooth();

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search booth',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
            
            // Grid
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                children: halls.map((hall) {
                  final hallBooths = filteredBooths.where((b) => b.hall == hall).toList();
                  if (hallBooths.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(hall, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: hallBooths.length,
                        itemBuilder: (context, index) {
                          // This calls the BoothCard class we just fixed
                          return BoothCard(
                            booth: hallBooths[index],
                            isSelected: selectedBoothId == hallBooths[index].id,
                            onTap: handleBoothTap,
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        
        // Modal logic (kept simple for brevity)
        if (showModal && booth != null)
           Positioned(
             bottom: 0, left: 0, right: 0,
             child: Container(
               color: Colors.white,
               padding: const EdgeInsets.all(24),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text("Selected: ${booth.id}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 10),
                   ElevatedButton(
                     onPressed: () => widget.onBoothSelected(booth), 
                     child: const Text("Confirm Selection")
                   )
                 ],
               ),
             ),
           )
      ],
    );
  }
}