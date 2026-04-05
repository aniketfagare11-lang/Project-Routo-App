import 'package:flutter/material.dart';

class ParcelDetailsScreen extends StatefulWidget {
  final String fromLocation;
  final String toLocation;

  const ParcelDetailsScreen({
    super.key,
    required this.fromLocation,
    required this.toLocation,
  });

  @override
  State<ParcelDetailsScreen> createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends State<ParcelDetailsScreen> {
  bool _isAccepting = false;
  
  // Track selected parcels by index (by default, auto-select all 5)
  final Set<int> _selectedIndices = {0, 1, 2, 3, 4};

  final List<Map<String, dynamic>> _mockParcels = [
    {
      'type': 'Box',
      'weight': '2.5 kg',
      'price': '₹50',
      'date': 'Today, 2:00 PM',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF1565C0),
    },
    {
      'type': 'Document',
      'weight': '0.5 kg',
      'price': '₹20',
      'date': 'Today, 4:30 PM',
      'icon': Icons.description_outlined,
      'color': const Color(0xFFD84315),
    },
    {
      'type': 'Electronics',
      'weight': '1.0 kg',
      'price': '₹30',
      'date': 'Tomorrow, 9:00 AM',
      'icon': Icons.laptop_chromebook_outlined,
      'color': const Color(0xFF5B3FBF),
    },
    {
      'type': 'Clothing',
      'weight': '1.5 kg',
      'price': '₹10',
      'date': 'Tomorrow, 11:00 AM',
      'icon': Icons.checkroom_outlined,
      'color': const Color(0xFF00838F),
    },
    {
      'type': 'Box',
      'weight': '3.0 kg',
      'price': '₹10',
      'date': 'Tomorrow, 1:00 PM',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF1565C0),
    },
  ];

  int get _totalEarnings {
    int total = 0;
    for (int i in _selectedIndices) {
      String priceStr = _mockParcels[i]['price'] as String;
      // Extract numeric value from "₹50"
      int price = int.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      total += price;
    }
    return total;
  }

  Future<void> _handleAcceptRoute() async {
    if (_selectedIndices.isEmpty) return;
    
    setState(() => _isAccepting = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isAccepting = false);
      
      // Show Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'Route Accepted!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You have successfully accepted ${_selectedIndices.length} parcels for delivery.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A97A6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context).pop(); // go back to home screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Go Back Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0D1B2A), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Route Details',
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRouteSummaryCard(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Parcels to Deliver',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    Text(
                      '${_selectedIndices.length} Selected',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5B3FBF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mockParcels.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final parcel = _mockParcels[index];
                    return _buildParcelItem(index, parcel);
                  },
                ),
                const SizedBox(height: 100), // padding for bottom button
              ],
            ),
          ),
          
          // Bottom Sticky Button Wrap
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: _buildPrimaryButton(
                text: _selectedIndices.isEmpty 
                    ? 'Select at least 1 parcel' 
                    : 'Accept ${_selectedIndices.length} Parcels & Start',
                icon: Icons.check_circle_rounded,
                isLoading: _isAccepting,
                onPressed: _selectedIndices.isEmpty ? () {} : _handleAcceptRoute,
                expand: true,
                isDisabled: _selectedIndices.isEmpty,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8ECF0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route_outlined, color: Color(0xFF1565C0)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fromLocation.split(',').first,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFF8A97A6)),
                        SizedBox(width: 4),
                        Text(
                          '148 km distance',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8A97A6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.toLocation.split(',').first,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A3412),
                  ),
                ),
                Text(
                  '₹$_totalEarnings',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEA580C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelItem(int index, Map<String, dynamic> parcel) {
    bool isSelected = _selectedIndices.contains(index);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIndices.remove(index);
          } else {
            _selectedIndices.add(index);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE8ECF0), 
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: isSelected 
             ? [
                 BoxShadow(
                   color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                   blurRadius: 10,
                   offset: const Offset(0, 4),
                 )
               ] 
             : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (parcel['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(parcel['icon'] as IconData, color: parcel['color'] as Color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        parcel['type'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                      Text(
                        parcel['price'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF166534), // Green for money
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.monitor_weight_outlined, size: 14, color: Color(0xFF8A97A6)),
                      const SizedBox(width: 4),
                      Text(
                        parcel['weight'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A97A6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF8A97A6)),
                      const SizedBox(width: 4),
                      Text(
                        parcel['date'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A97A6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Custom Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF22C55E) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected 
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool expand = false,
    bool isDisabled = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: expand ? double.infinity : null,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDisabled 
              ? [const Color(0xFFB0BAC5), const Color(0xFF8A97A6)] // Greyed out if disabled
              : [const Color(0xFF5B3FBF), const Color(0xFF1565C0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: isDisabled ? [] : [
          BoxShadow(
            color: const Color(0xFF5B3FBF).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: (isLoading || isDisabled) ? null : onPressed,
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.2)),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
