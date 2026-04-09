import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'add_parcel_screen.dart';
import 'parcel_details_screen.dart';

// ─────────────────────────────────────────────
//  Design Tokens (matches auth screens exactly)
// ─────────────────────────────────────────────
class _RoutoColors {
  static const bgGradient = [
    Color(0xFF0D47A1),
    Color(0xFF1565C0),
    Color(0xFF1976D2),
    Color(0xFFE65100),
    Color(0xFFFF6F00),
  ];
  static const bgStops = [0.0, 0.25, 0.45, 0.78, 1.0];

  static const primaryGrad = [Color(0xFF1565C0), Color(0xFFE65100)];
  static const secondaryGrad = [Color(0xFF5B3FBF), Color(0xFF1565C0)];

  static const cardBg = Colors.white;
  static const pageBg = Color(0xFFF5F7FA);
  static const fieldBg = Color(0xFFF5F7FA);
  static const fieldBorder = Color(0xFFE8ECF0);

  static const textPrimary = Color(0xFF0D1B2A);
  static const textSecondary = Color(0xFF8A97A6);

  static const accentPurple = Color(0xFF5B3FBF);
  static const accentRed = Color(0xFFD84315);
}

// ─────────────────────────────────────────────
//  HomeScreen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSearching = false;
  bool _showResults = false;

  final TextEditingController _fromController =
      TextEditingController(text: 'Pune, Maharashtra');
  final TextEditingController _toController =
      TextEditingController(text: 'Mumbai, Maharashtra');

  // ── Animations ──────────────────────────────
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _headerSlide;
  late Animation<Offset> _contentSlide;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // ── Handlers ────────────────────────────────
  void _handleSwap() {
    setState(() {
      final temp = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = temp;
      _showResults = false;
    });
  }

  Future<void> _handleSearch() async {
    if (_fromController.text.trim().isEmpty ||
        _toController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both locations')),
      );
      return;
    }
    setState(() {
      _isSearching = true;
      _showResults = false;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isSearching = false;
        _showResults = true;
      });
    }
  }

  // ── Build ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RoutoColors.pageBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ── Gradient Header ──────────────
                  SlideTransition(
                    position: _headerSlide,
                    child: _buildGradientHeader(),
                  ),
                  // ── Body Content ────────────────
                  SlideTransition(
                    position: _contentSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 8.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildSectionLabel('Find Your Route'),
                              const SizedBox(height: 12),
                              _buildSelectRouteCard(),
                              if (_showResults) ...[
                                const SizedBox(height: 20),
                                _buildResultsCard(),
                              ],
                              const SizedBox(height: 20),
                              _buildSectionLabel('Quick Actions'),
                              const SizedBox(height: 12),
                              _buildQuickActions(),
                              const SizedBox(height: 20),
                              _buildSectionLabel('Recent Activity'),
                              const SizedBox(height: 12),
                              _buildRecentActivity(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: _buildFAB(), removed as per user request
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ── Gradient Header ────────────────────────────────────────────────────────
  Widget _buildGradientHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _RoutoColors.bgGradient,
          stops: _RoutoColors.bgStops,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          // Decorative circles (same as auth screens)
          Positioned(
            top: -40,
            right: -50,
            child: _buildDecoCircle(180, Colors.white.withValues(alpha: 0.04)),
          ),
          Positioned(
            top: 60,
            left: -60,
            child: _buildDecoCircle(140, Colors.white.withValues(alpha: 0.03)),
          ),
          Positioned(
            bottom: 20,
            right: 40,
            child: _buildDecoCircle(80, Colors.white.withValues(alpha: 0.04)),
          ),
          // Route dots painter (same as auth screens)
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(36)),
              child: CustomPaint(painter: HomeRouteDotsPainter()),
            ),
          ),
          // Header content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 24),
                  _buildGreeting(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecoCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF6F00).withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 2),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFFE65100)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'R',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFFFCC80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'ROUTO',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 5,
                ),
              ),
            ),
          ],
        ),
        // Action icons
        Row(
          children: [
            _buildHeaderIconBtn(Icons.notifications_outlined),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4), width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIconBtn(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.2), width: 0.8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFCC80), size: 14),
              SizedBox(width: 6),
              Text(
                'Good morning!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Ready to deliver\ntoday?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Move Smart. Deliver Faster.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
            child: _buildStatChip(
                Icons.inventory_2_outlined, '5', 'Active Parcels')),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatChip(
                Icons.currency_rupee_rounded, '₹360', 'Today\'s Earnings')),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatChip(Icons.star_rounded, '4.9', 'Rating')),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.18), width: 0.8),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFCC80), size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _RoutoColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  // ── Select Route Card ──────────────────────────────────────────────────────
  Widget _buildSelectRouteCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map_outlined,
                    color: _RoutoColors.accentPurple, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Select Route',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _RoutoColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // From / Swap row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildLocationInput(
                  controller: _fromController,
                  label: 'From',
                  iconColor: _RoutoColors.accentPurple,
                ),
              ),
              const SizedBox(width: 12),
              _buildSwapButton(),
            ],
          ),
          const SizedBox(height: 12),
          // To
          _buildLocationInput(
            controller: _toController,
            label: 'To',
            iconColor: _RoutoColors.accentRed,
          ),
          const SizedBox(height: 20),
          // Primary CTA — blue → orange (same as auth screens)
          _buildPrimaryButton(
            text: 'Find Available Parcels',
            icon: Icons.search_rounded,
            isLoading: _isSearching,
            onPressed: _handleSearch,
            gradient: _RoutoColors.primaryGrad,
            shadowColor: const Color(0xFF1565C0),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return GestureDetector(
      onTap: _handleSwap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _RoutoColors.accentPurple.withValues(alpha: 0.2),
              width: 1),
        ),
        child: const Icon(Icons.swap_vert_rounded,
            color: _RoutoColors.accentPurple, size: 22),
      ),
    );
  }

  Widget _buildLocationInput({
    required TextEditingController controller,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _RoutoColors.fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _RoutoColors.fieldBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _RoutoColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: controller,
                  onChanged: (val) {
                    if (_showResults) setState(() => _showResults = false);
                  },
                  style: const TextStyle(
                    color: _RoutoColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Results Card ───────────────────────────────────────────────────────────
  Widget _buildResultsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FAF0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: Color(0xFF166534), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Route Results',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _RoutoColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Route success pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Route Found Successfully!',
                        style: TextStyle(
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_fromController.text.split(',').first} → ${_toController.text.split(',').first}',
                        style: const TextStyle(
                          color: _RoutoColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildParcelInfoBox(),
          const SizedBox(height: 12),
          _buildEarningsBox(),
          const SizedBox(height: 20),
          // Accept CTA — same blue→orange gradient as login/signup
          _buildPrimaryButton(
            text: 'Accept & View Details',
            icon: Icons.inventory_rounded,
            gradient: _RoutoColors.primaryGrad,
            shadowColor: const Color(0xFF1565C0),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ParcelDetailsScreen(
                    fromLocation: _fromController.text,
                    toLocation: _toController.text,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParcelInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF86EFAC),
            width: 1.2,
            strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: const Center(
              child: Text('📦', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Parcels',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _RoutoColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '5',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF166534),
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Parcels on route',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Waiting to be picked up',
                  style: TextStyle(
                    color: _RoutoColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFEDD5), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.currency_rupee_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Earn up to ',
                style: TextStyle(
                    color: Color(0xFF9A3412),
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                    text: '₹120',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15.5),
                  ),
                  TextSpan(text: ' on this route'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionTile(
            icon: Icons.add_box_rounded,
            label: 'Add Parcel',
            sublabel: 'Post a package',
            gradient: _RoutoColors.secondaryGrad,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddParcelScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionTile(
            icon: Icons.route_rounded,
            label: 'My Routes',
            sublabel: 'View saved routes',
            gradient: _RoutoColors.primaryGrad,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String label,
    required String sublabel,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sublabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Activity ────────────────────────────────────────────────────────
  Widget _buildRecentActivity() {
    final activities = [
      const _ActivityItem(
        emoji: '📦',
        title: 'Parcel to Mumbai',
        subtitle: 'Picked up · 2 hours ago',
        status: 'In Transit',
        statusColor: Color(0xFF1565C0),
        statusBg: Color(0xFFEEF2FF),
      ),
      const _ActivityItem(
        emoji: '✅',
        title: 'Parcel to Nashik',
        subtitle: 'Delivered · Yesterday',
        status: 'Delivered',
        statusColor: Color(0xFF166534),
        statusBg: Color(0xFFDCFCE7),
      ),
      const _ActivityItem(
        emoji: '🕐',
        title: 'Parcel to Pune',
        subtitle: 'Waiting · 3 hours ago',
        status: 'Pending',
        statusColor: Color(0xFF9A3412),
        statusBg: Color(0xFFFFF7ED),
      ),
    ];

    return _buildCard(
      child: Column(
        children: activities
            .asMap()
            .entries
            .map((entry) => Column(
                  children: [
                    _buildActivityTile(entry.value),
                    if (entry.key < activities.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                            height: 0.8, color: _RoutoColors.fieldBorder),
                      ),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget _buildActivityTile(_ActivityItem item) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _RoutoColors.fieldBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _RoutoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: _RoutoColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: item.statusBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item.status,
            style: TextStyle(
              color: item.statusColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ── Reusable: White Card ───────────────────────────────────────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _RoutoColors.cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  // ── Reusable: Primary Button ───────────────────────────────────────────────
  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required List<Color> gradient,
    required Color shadowColor,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 16),
                  ],
                ),
        ),
      ),
    );
  }


  // ── Bottom Navigation Bar ──────────────────────────────────────────────────
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_filled, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.map_rounded, Icons.map_outlined, 'Map'),
              _buildNavItem(2, Icons.insights_rounded,
                  Icons.insights_outlined, 'Analytics'),
              _buildNavItem(3, Icons.person_rounded,
                  Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? _RoutoColors.accentPurple
        : _RoutoColors.textSecondary;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _RoutoColors.accentPurple.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : inactiveIcon, color: color,
                size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Activity Item Model
// ─────────────────────────────────────────────
class _ActivityItem {
  final String emoji;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final Color statusBg;

  const _ActivityItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });
}

// ─────────────────────────────────────────────
//  Custom Painter — Route Dots (same style as auth)
// ─────────────────────────────────────────────
class HomeRouteDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dotRadius = 3.0;
    final points = [
      Offset(size.width * 0.10, size.height * 0.12),
      Offset(size.width * 0.30, size.height * 0.22),
      Offset(size.width * 0.18, size.height * 0.50),
      Offset(size.width * 0.45, size.height * 0.65),
      Offset(size.width * 0.80, size.height * 0.30),
      Offset(size.width * 0.90, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.85),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      const dashLength = 6.0;
      const gapLength = 5.0;
      final dx = points[i + 1].dx - points[i].dx;
      final dy = points[i + 1].dy - points[i].dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      final nx = dx / dist;
      final ny = dy / dist;
      double traveled = 0;
      bool drawing = true;
      while (traveled < dist) {
        final segEnd =
            math.min(traveled + (drawing ? dashLength : gapLength), dist);
        if (drawing) {
          canvas.drawLine(
            Offset(points[i].dx + nx * traveled, points[i].dy + ny * traveled),
            Offset(points[i].dx + nx * segEnd, points[i].dy + ny * segEnd),
            linePaint,
          );
        }
        traveled = segEnd;
        drawing = !drawing;
      }
    }

    for (final point in points) {
      canvas.drawCircle(point, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
