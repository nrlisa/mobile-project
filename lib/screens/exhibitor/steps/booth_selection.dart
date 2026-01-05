import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/db_service.dart';
import '../../../models/booth.dart';

class BoothSelection extends StatefulWidget {
  final String eventId; // Ensure this is passed from the parent
  final Function(Booth) onBoothSelected; // Changed from String to Booth object for better data flow
  final VoidCallback onBack;

  const BoothSelection({
    super.key,
    required this.eventId,
    required this.onBoothSelected,
    required this.onBack,
  });

  @override
  State<BoothSelection> createState() => _BoothSelectionState();
}

class _BoothSelectionState extends State<BoothSelection> {
  final DbService _dbService = DbService();
  Booth? _selectedBooth;
  String? _floorPlanUrl;
  bool _isMapView = false;
  List<Booth> _cachedBooths = [];
  String? _userCategory;
  bool _competitorCheckEnabled = false;
  final List<String> _categories = ['Technology', 'Food & Beverage', 'Healthcare', 'Automotive', 'Fashion', 'Education', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadFloorPlan();
    _fetchUserCategory();
    _fetchEventSettings();
  }

  Future<void> _fetchEventSettings() async {
    try {
      final data = await _dbService.getEventData(widget.eventId);
      if (mounted) {
        setState(() {
          _competitorCheckEnabled = data['competitorCheckEnabled'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching event settings: $e");
    }
  }

  Future<void> _fetchUserCategory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _dbService.getUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _userCategory = profile['companyCategory'] ?? profile['category'];
        });
      }
    }
  }

  Future<void> _loadFloorPlan() async {
    final url = await _dbService.getEffectiveFloorPlanUrl(widget.eventId);
    if (mounted) setState(() => _floorPlanUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Booth>>(
      stream: _dbService.getBoothsStream(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading booths: ${snapshot.error}"));
        }

        final booths = snapshot.data ?? [];
        _cachedBooths = booths;

        // Filter booths by Hall/Size logic
        final hallABooths = booths.where((b) => b.size == 'Small' || b.boothNumber.startsWith('S')).toList()..sort(_compareBoothNumbers);
        final hallBBooths = booths.where((b) => b.size == 'Medium' || b.boothNumber.startsWith('M')).toList()..sort(_compareBoothNumbers);
        final hallCBooths = booths.where((b) => b.size == 'Large' || b.boothNumber.startsWith('L')).toList()..sort(_compareBoothNumbers);

        return Column(
          children: [
            _buildCategorySelector(),
            _buildViewToggle(),
            _buildLegend(),
            Expanded(
              child: _isMapView
                  ? _buildFloorPlan(booths)
                  : DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            tabs: [
                              Tab(text: "Hall A (Small)"),
                              Tab(text: "Hall B (Medium)"),
                              Tab(text: "Hall C (Large)"),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildBoothGrid(hallABooths),
                                _buildBoothGrid(hallBBooths),
                                _buildBoothGrid(hallCBooths),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            _buildBottomNav(),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue[50],
      child: Row(
        children: [
          const Text("My Category: ", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButton<String>(
              value: _categories.contains(_userCategory) ? _userCategory : null,
              hint: const Text("Select Category"),
              isExpanded: true,
              underline: Container(height: 1, color: Colors.blue),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (val) => setState(() => _userCategory = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("View: ", style: TextStyle(fontWeight: FontWeight.bold)),
          ToggleButtons(
            isSelected: [!_isMapView, _isMapView],
            onPressed: (index) => setState(() => _isMapView = index == 1),
            borderRadius: BorderRadius.circular(8),
            constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
            children: const [
              Icon(Icons.grid_view, size: 20),
              Icon(Icons.map, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  int _compareBoothNumbers(Booth a, Booth b) {
    try {
      final int aNum = int.parse(a.boothNumber.split('-').last);
      final int bNum = int.parse(b.boothNumber.split('-').last);
      return aNum.compareTo(bNum);
    } catch (e) {
      return a.boothNumber.compareTo(b.boothNumber);
    }
  }

  Widget _buildBoothGrid(List<Booth> booths) {
    if (booths.isEmpty) {
      return const Center(child: Text("No booths available in this hall"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: booths.length,
      itemBuilder: (context, index) {
        final booth = booths[index];
        bool isSelected = _selectedBooth?.id == booth.id;
        bool isBooked = booth.status.toLowerCase() == 'booked';

        Color bgColor = isSelected 
            ? Colors.blue 
            : (isBooked ? Colors.red : Colors.green);

        return GestureDetector(
          onTap: isBooked
              ? null
              : () {
                  final error = _validateCompetitorAdjacency(booth);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error), backgroundColor: Colors.red));
                  } else {
                    _showBoothPopup(booth);
                  }
                },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                booth.boothNumber,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloorPlan(List<Booth> booths) {
    if (_floorPlanUrl == null || _floorPlanUrl!.isEmpty) {
      return const Center(child: Text("No floor plan map available."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Floor Plan Image
                Positioned.fill(child: _buildImage(_floorPlanUrl!)),

                // 2. Booth Overlays
                ...booths.map((booth) {
                  if (booth.x == null || booth.y == null) return const SizedBox.shrink();
                  final isSelected = _selectedBooth?.id == booth.id;
                  
                  return _ExhibitorBoothItem(
                    booth: booth,
                    parentSize: Size(constraints.maxWidth, constraints.maxHeight),
                    isSelected: isSelected,
                    onTap: () {
                      final error = _validateCompetitorAdjacency(booth);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(error), backgroundColor: Colors.red));
                      } else {
                        _showBoothPopup(booth);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('data:image')) {
      try {
        final base64String = url.split(',').last.replaceAll(RegExp(r'\s+'), '');
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.fill,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
        );
      } catch (e) {
        return const Center(child: Icon(Icons.error));
      }
    }
    return Image.network(
      url,
      fit: BoxFit.fill,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.broken_image, size: 50, color: Colors.grey), Text("Map not available")],
          ),
        ),
      ),
    );
  }

  void _showBoothPopup(Booth booth) {
    final isAvailable = booth.status.toLowerCase() == 'available';
    String dimensions = (booth.size == "Small") ? "3m x 3m" : (booth.size == "Medium") ? "5m x 5m" : "8m x 8m";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    "Booth ${booth.boothNumber}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    "RM ${booth.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Details
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Category", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${booth.size} Booth", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dimensions", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(dimensions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Amenities", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text("• 1x Power Socket (13A)\n• Shared WiFi Access\n• 1x Table & 2x Chairs", 
                    style: TextStyle(fontSize: 14, height: 1.5)),

                  const SizedBox(height: 24),
                  
                  // Status
                  Row(
                    children: [
                      Icon(
                        isAvailable ? Icons.check_circle : Icons.error,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAvailable ? "Available" : "Unavailable",
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isAvailable
                        ? () {
                            final error = _validateCompetitorAdjacency(booth);
                            if (error != null) {
                              // Keep dialog open and show error
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(error), 
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ));
                            } else {
                              setState(() => _selectedBooth = booth);
                              Navigator.pop(context);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[500],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("SELECT BOOTH"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(onPressed: widget.onBack, child: const Text("BACK")),
          ElevatedButton(
            onPressed: _selectedBooth == null 
                ? null 
                : () async {
                    // Save category to profile so it autofills in the Application Form
                    if (_userCategory != null) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await _dbService.updateUser(user.uid, {'companyCategory': _userCategory});
                      }
                    }
                    widget.onBoothSelected(_selectedBooth!);
                  },
            child: const Text("NEXT"),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.green, "Available"),
          const SizedBox(width: 15),
          _legendItem(Colors.red, "Booked"),
          const SizedBox(width: 15),
          _legendItem(Colors.blue, "Selected"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      );

  String? _validateCompetitorAdjacency(Booth targetBooth) {
    if (!_competitorCheckEnabled) return null;
    debugPrint("Competitor check is ENABLED for this event.");
    
    // If user has no category, we can't check adjacency, but we should probably warn them or allow.
    // Assuming allow, but logging for debug.
    if (_userCategory == null || _userCategory!.isEmpty) {
      // Return an error forcing them to select a category first
      return "Please select your 'Company Category' at the top of the screen before selecting a booth.";
    }
    debugPrint("Current user category: $_userCategory");

    // Determine context list (Hall) based on size/number to match GridView logic
    List<Booth> contextList;
    if (targetBooth.size == 'Small' || targetBooth.boothNumber.startsWith('S')) {
       contextList = _cachedBooths.where((b) => b.size == 'Small' || b.boothNumber.startsWith('S')).toList()..sort(_compareBoothNumbers);
    } else if (targetBooth.size == 'Medium' || targetBooth.boothNumber.startsWith('M')) {
       contextList = _cachedBooths.where((b) => b.size == 'Medium' || b.boothNumber.startsWith('M')).toList()..sort(_compareBoothNumbers);
    } else {
       contextList = _cachedBooths.where((b) => b.size == 'Large' || b.boothNumber.startsWith('L')).toList()..sort(_compareBoothNumbers);
    }

    int index = contextList.indexWhere((b) => b.id == targetBooth.id);
    if (index == -1) return null;

    int crossAxisCount = 3; 

    bool isCompetitor(int idx) {
      if (idx < 0 || idx >= contextList.length) return false;
      final neighbor = contextList[idx];
      if (neighbor.status == 'available') return false; 
      debugPrint("Checking neighbor ${neighbor.boothNumber} with category: ${neighbor.companyCategory}");
      return neighbor.companyCategory?.toLowerCase() == _userCategory!.toLowerCase();
    }

    if (index % crossAxisCount != 0 && isCompetitor(index - 1)) return "Cannot select: Left neighbor is a competitor.";
    if ((index + 1) % crossAxisCount != 0 && isCompetitor(index + 1)) return "Cannot select: Right neighbor is a competitor.";
    if (isCompetitor(index - crossAxisCount)) return "Cannot select: Top neighbor is a competitor.";
    if (isCompetitor(index + crossAxisCount)) return "Cannot select: Bottom neighbor is a competitor.";

    return null;
  }
}

class _ExhibitorBoothItem extends StatelessWidget {
  final Booth booth;
  final Size parentSize;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExhibitorBoothItem({
    required this.booth,
    required this.parentSize,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double x = (booth.x ?? 0.0) * parentSize.width;
    double y = (booth.y ?? 0.0) * parentSize.height;
    double width = (booth.width ?? 0.1) * parentSize.width;
    double height = (booth.height ?? 0.08) * parentSize.height;

    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _getBoothColor().withValues(alpha: 0.7),
            border: Border.all(
              color: isSelected ? Colors.yellow : Colors.white,
              width: isSelected ? 2.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              booth.boothNumber,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBoothColor() {
    if (isSelected) return Colors.blue;
    return booth.status.toLowerCase() == 'available' ? Colors.green : Colors.red;
  }
}