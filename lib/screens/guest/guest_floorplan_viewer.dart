import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/db_service.dart';
import '../../models/booth.dart';

class GuestFloorplanViewer extends StatefulWidget {
  final String eventId;
  final String eventName;

  const GuestFloorplanViewer({
    super.key, 
    required this.eventId, 
    required this.eventName
  });

  @override
  State<GuestFloorplanViewer> createState() => _GuestFloorplanViewerState();
}

class _GuestFloorplanViewerState extends State<GuestFloorplanViewer> {
  final DbService _dbService = DbService();
  String? _floorPlanUrl;
  bool _isLoadingMap = true;
  bool _isMapView = false;
  late Stream<List<Booth>> _boothsStream;

  @override
  void initState() {
    super.initState();
    _boothsStream = _dbService.getBoothsStream(widget.eventId);
    _loadFloorPlan();
  }

  Future<void> _loadFloorPlan() async {
    setState(() => _isLoadingMap = true);
    final url = await _dbService.getEffectiveFloorPlanUrl(widget.eventId);
    if (mounted) {
      setState(() {
        _floorPlanUrl = url;
        _isLoadingMap = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/guest');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFloorPlan,
          ),
        ],
      ),
      body: StreamBuilder<List<Booth>>(
        stream: _boothsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          
          final booths = snapshot.data ?? [];

          // Separate Hall Data
          final hallABooths = booths.where((b) => b.size == 'Small' || b.boothNumber.startsWith('S')).toList()..sort(_compareBoothNumbers);
          final hallBBooths = booths.where((b) => b.size == 'Medium' || b.boothNumber.startsWith('M')).toList()..sort(_compareBoothNumbers);
          final hallCBooths = booths.where((b) => b.size == 'Large' || b.boothNumber.startsWith('L')).toList()..sort(_compareBoothNumbers);

          return Column(
            children: [
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
                                Tab(text: "Hall A"),
                                Tab(text: "Hall B"),
                                Tab(text: "Hall C"),
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("View Mode: ", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.green, "Available"),
          const SizedBox(width: 15),
          _legendItem(Colors.red, "Sold"),
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
      return const Center(child: Text("No booths in this hall"));
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
        bool isBooked = booth.status.toLowerCase() == 'booked';

        return GestureDetector(
          onTap: () => _showBoothInfoPopup(booth),
          child: Container(
            decoration: BoxDecoration(
              color: isBooked ? Colors.red : Colors.green,
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
    if (_isLoadingMap) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_floorPlanUrl == null || _floorPlanUrl!.isEmpty) {
      return const Center(child: Text("Map layout not available."));
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
                Positioned.fill(child: _buildImage(_floorPlanUrl)),
                ...booths.map((booth) {
                  if (booth.x == null || booth.y == null) return const SizedBox.shrink();
                  return _GuestBoothItem(
                    booth: booth,
                    parentSize: Size(constraints.maxWidth, constraints.maxHeight),
                    onTap: () => _showBoothInfoPopup(booth),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBoothInfoPopup(Booth booth) {
    bool isBooked = booth.status.toLowerCase() == 'booked';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Booth ${booth.boothNumber}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Size: ${booth.size}"),
            const SizedBox(height: 8),
            Text("Status: ${isBooked ? 'Occupied' : 'Available'}"),
            if (isBooked && booth.companyName != null) ...[
              const SizedBox(height: 8),
              Text("Exhibitor: ${booth.companyName}", 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE")),
        ],
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return _buildError();

    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',').last.replaceAll(RegExp(r'\s+'), '');
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.fill,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _buildError(),
        );
      } catch (e) {
        return _buildError();
      }
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) => _buildError(),
    );
  }

  Widget _buildError() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, color: Colors.grey, size: 50),
          Text("Image Load Failed", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _GuestBoothItem extends StatelessWidget {
  final Booth booth;
  final Size parentSize;
  final VoidCallback onTap;

  const _GuestBoothItem({
    required this.booth,
    required this.parentSize,
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
            color: (booth.status.toLowerCase() == 'booked' ? Colors.red : Colors.green).withValues(alpha: 0.7),
            border: Border.all(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              booth.boothNumber,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}