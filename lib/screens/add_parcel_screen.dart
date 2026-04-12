import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS — Premium Dark Theme (Synced with HomeScreen)
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  // Background
  static const bg0 = Color(0xFF0B0F1A); // top
  static const bg1 = Color(0xFF121A2F); // middle
  static const bg2 = Color(0xFF05070D); // bottom

  // Glass surfaces
  static const glass = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const glassBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const glassDeep = Color(0x08FFFFFF); // even more subtle fill

  // Accents
  static const purple = Color(0xFF7C5CFF);
  static const blue = Color(0xFF4DA1FF);
  static const orange = Color(0xFFFF8A3D);

  // Semantic / status
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const cyan = Color(0xFF5CF0FC);

  // Text
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSec = Color(0xFF94A3B8); // ~70% white-ish gray

  // Glow helpers
  static Color purpleGlow(double a) => purple.withValues(alpha: a);
  static Color blueGlow(double a) => blue.withValues(alpha: a);
  static Color orangeGlow(double a) => orange.withValues(alpha: a);
}

class AddParcelScreen extends StatefulWidget {
  const AddParcelScreen({super.key});

  @override
  State<AddParcelScreen> createState() => _AddParcelScreenState();
}

class _AddParcelScreenState extends State<AddParcelScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _dateController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();

  // ── Focus nodes ───────────────────────────────────────────────────────────
  final _pickupFocus = FocusNode();
  final _dropoffFocus = FocusNode();
  final _weightFocus = FocusNode();
  final _priceFocus = FocusNode();

  // ── Validation ────────────────────────────────────────────────────────────
  String? _pickupError;
  String? _dropoffError;
  String? _dateError;
  String? _weightError;

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isFetchingLocation = false;
  int _selectedTypeIndex = 0;
  bool _isPriceSuggested = true;

  // ── Animation controllers ─────────────────────────────────────────────────
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _successController;
  late AnimationController _buttonController;
  late AnimationController _bgOrbitCtrl;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _successAnim;
  late Animation<double> _buttonScaleAnim;
  late Animation<double> _bgOrbitAnim;

  // ── Parcel types ──────────────────────────────────────────────────────────
  final _parcelTypes = <Map<String, Object>>[
    {'label': 'Box', 'icon': Icons.inventory_2_rounded, 'color': _C.blue},
    {'label': 'Fragile', 'icon': Icons.wine_bar_rounded, 'color': _C.orange},
    {'label': 'Document', 'icon': Icons.description_rounded, 'color': _C.cyan},
    {'label': 'Electronics', 'icon': Icons.devices_rounded, 'color': _C.purple},
    {'label': 'Other', 'icon': Icons.more_horiz_rounded, 'color': _C.green},
  ];

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _successController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _bgOrbitCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 16))
          ..repeat();

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));
    _successAnim =
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut);
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));
    _bgOrbitAnim = CurvedAnimation(parent: _bgOrbitCtrl, curve: Curves.linear);

    _fadeController.forward();
    _slideController.forward();

    _weightController.addListener(_onWeightChanged);
    for (final fn in [_pickupFocus, _dropoffFocus, _weightFocus, _priceFocus]) {
      fn.addListener(() => setState(() {}));
    }
  }

  void _onWeightChanged() {
    final weight = double.tryParse(_weightController.text);
    if (weight != null) {
      final suggested = weight < 2
          ? '100'
          : weight <= 5
              ? '200'
              : '300';
      if (_priceController.text.isEmpty || _isPriceSuggested) {
        _priceController.text = suggested;
        _isPriceSuggested = true;
      }
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _dateController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _pickupFocus.dispose();
    _dropoffFocus.dispose();
    _weightFocus.dispose();
    _priceFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _successController.dispose();
    _buttonController.dispose();
    _bgOrbitCtrl.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isFetchingLocation = false;
        _pickupController.text = 'Chennai, Tamil Nadu';
        _pickupError = null;
      });
    }
  }

  Future<void> _selectDate() async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _C.purple,
            onPrimary: Colors.white,
            surface: Color(0xFF121A2F),
            onSurface: Colors.white,
          ),
          dialogTheme: DialogThemeData(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        _dateError = null;
      });
    }
  }

  bool _validate() {
    setState(() {
      _pickupError = _pickupController.text.trim().isEmpty
          ? 'Pickup location is required'
          : null;
      _dropoffError = _dropoffController.text.trim().isEmpty
          ? 'Drop-off location is required'
          : null;
      _dateError = _dateController.text.trim().isEmpty
          ? 'Please select a pickup date'
          : null;
      _weightError =
          _weightController.text.trim().isEmpty ? 'Enter parcel weight' : null;
    });
    return _pickupError == null &&
        _dropoffError == null &&
        _dateError == null &&
        _weightError == null;
  }

  Future<void> _handleSubmit() async {
    HapticFeedback.mediumImpact();
    if (!_validate()) return;

    await _buttonController.forward();
    await _buttonController.reverse();

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
      _successController.forward();
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg2,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(children: [
        _buildBackground(),
        FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildLocationCard(),
                    const SizedBox(height: 16),
                    _buildParcelTypeCard(),
                    const SizedBox(height: 16),
                    _buildParcelDetailsCard(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isSuccess) _buildSuccessOverlay(),
      ]),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _C.glass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.glassBorder),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
      ),
      title: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          colors: [_C.purple, _C.blue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: const Text(
          'Add Parcel',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
    );
  }

  // ── Animated Background ───────────────────────────────────────────────────
  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _bgOrbitAnim,
      builder: (_, __) {
        final t = _bgOrbitAnim.value * 2 * math.pi;
        return Stack(children: [
          // Base tri-stop gradient — dark navy → deep blue → black
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_C.bg0, _C.bg1, _C.bg2],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Radial noise texture overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -0.7),
                radius: 1.2,
                colors: [
                  _C.purple.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Orbiting orbs
          _orb(
            x: 0.12 + 0.07 * math.cos(t),
            y: 0.10 + 0.05 * math.sin(t),
            size: 260,
            color: _C.purpleGlow(0.10),
          ),
          _orb(
            x: 0.82 + 0.05 * math.cos(t + 2.0),
            y: 0.32 + 0.06 * math.sin(t + 2.0),
            size: 200,
            color: _C.blueGlow(0.08),
          ),
          _orb(
            x: 0.45 + 0.06 * math.cos(t + 4.1),
            y: 0.70 + 0.04 * math.sin(t + 4.1),
            size: 170,
            color: _C.orangeGlow(0.07),
          ),
        ]);
      },
    );
  }

  Widget _orb({
    required double x,
    required double y,
    required double size,
    required Color color,
  }) {
    return LayoutBuilder(builder: (ctx, c) {
      return Positioned(
        left: c.maxWidth * x - size / 2,
        top: c.maxHeight * y - size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, Colors.transparent]),
          ),
        ),
      );
    });
  }

  // ── Location Card ─────────────────────────────────────────────────────────
  Widget _buildLocationCard() {
    return _glassCard(
      accentColor: _C.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.route_rounded, 'Location Details', _C.blue),
          const SizedBox(height: 20),
          _buildGlowInput(
            controller: _pickupController,
            focusNode: _pickupFocus,
            label: 'Pickup Location',
            hint: 'E.g., Pune, Maharashtra',
            icon: Icons.my_location_rounded,
            focusColor: _C.blue,
            error: _pickupError,
            suffix: _isFetchingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _C.blue),
                  )
                : GestureDetector(
                    onTap: _fetchCurrentLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(colors: [_C.purple, _C.blue]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: _C.purpleGlow(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.gps_fixed_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('GPS',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          // Dashed connector
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              children: List.generate(
                  3,
                  (_) => Container(
                        width: 2,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 3),
                        decoration: BoxDecoration(
                          color: _C.textSec.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
            ),
          ),
          const SizedBox(height: 8),
          _buildGlowInput(
            controller: _dropoffController,
            focusNode: _dropoffFocus,
            label: 'Drop-off Location',
            hint: 'E.g., Mumbai, Maharashtra',
            icon: Icons.location_on_rounded,
            focusColor: _C.orange,
            error: _dropoffError,
          ),
        ],
      ),
    );
  }

  // ── Parcel Type Card ──────────────────────────────────────────────────────
  Widget _buildParcelTypeCard() {
    return _glassCard(
      accentColor: _C.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.category_rounded, 'Parcel Type', _C.cyan),
          const SizedBox(height: 18),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _parcelTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final type = _parcelTypes[i];
                final selected = _selectedTypeIndex == i;
                final color = type['color'] as Color;
                // Selected always glows purple
                final glowColor = selected ? _C.purple : color;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTypeIndex = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 74,
                    decoration: BoxDecoration(
                      color: selected
                          ? _C.purple.withValues(alpha: 0.15)
                          : _C.glassDeep,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? _C.purple.withValues(alpha: 0.75)
                            : _C.glassBorder,
                        width: selected ? 1.5 : 1.0,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: _C.purpleGlow(0.40),
                                  blurRadius: 20,
                                  spreadRadius: 0),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selected
                                ? _C.purple.withValues(alpha: 0.22)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            type['icon'] as IconData,
                            color: selected ? _C.purple : _C.textSec,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          type['label'] as String,
                          style: TextStyle(
                            color: selected ? _C.purple : _C.textSec,
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Parcel Details Card ───────────────────────────────────────────────────
  Widget _buildParcelDetailsCard() {
    return _glassCard(
      accentColor: _C.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.inventory_2_rounded, 'Parcel Details', _C.purple),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildGlowInput(
                  controller: _weightController,
                  focusNode: _weightFocus,
                  label: 'Weight (kg)',
                  hint: '2.5',
                  icon: Icons.monitor_weight_outlined,
                  focusColor: _C.purple,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  error: _weightError,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGlowInput(
                      controller: _priceController,
                      focusNode: _priceFocus,
                      label: 'Price (₹)',
                      hint: 'Auto',
                      icon: Icons.currency_rupee_rounded,
                      focusColor: _C.green,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _isPriceSuggested = false,
                    ),
                    if (_isPriceSuggested && _priceController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 4),
                        child: Row(children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 10, color: _C.green),
                          const SizedBox(width: 3),
                          Text('Suggested',
                              style: TextStyle(
                                color: _C.green.withValues(alpha: 0.85),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              )),
                        ]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildGlowInput(
            controller: _dateController,
            label: 'Pickup Date',
            hint: 'Select a date',
            icon: Icons.calendar_month_rounded,
            focusColor: _C.cyan,
            readOnly: true,
            onTap: _selectDate,
            error: _dateError,
          ),
        ],
      ),
    );
  }

  // ── Submit Button ─────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return ScaleTransition(
      scale: _buttonScaleAnim,
      child: GestureDetector(
        onTap: _isLoading ? null : _handleSubmit,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [_C.purple, _C.orange],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _C.purpleGlow(0.45),
                blurRadius: 28,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: _C.orangeGlow(0.20),
                blurRadius: 20,
                offset: const Offset(8, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Submit Parcel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Success Overlay ───────────────────────────────────────────────────────
  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          color: Colors.black.withValues(alpha: 0.65),
          child: Center(
            child: ScaleTransition(
              scale: _successAnim,
              child: Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: _C.bg1,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _C.green.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: _C.green.withValues(alpha: 0.22),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: _C.purpleGlow(0.15),
                      blurRadius: 60,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _C.green.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: _C.green.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: _C.green, size: 44),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Parcel Added!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your parcel has been submitted\nsuccessfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  REUSABLE COMPONENTS
  // ─────────────────────────────────────────────────────────────────────────

  /// Glassmorphism card with subtle top-accent shimmer
  Widget _glassCard({required Widget child, Color? accentColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            // rgba(255,255,255,0.05)
            color: _C.glass,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _C.glassBorder),
            // Subtle top-edge accent line
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (accentColor ?? _C.purple).withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.02),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _cardHeader(IconData icon, String title, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(
          color: _C.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    ]);
  }

  Widget _buildGlowInput({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required Color focusColor,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
    String? error,
    ValueChanged<String>? onChanged,
  }) {
    final isFocused = focusNode?.hasFocus ?? false;
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: isFocused ? focusColor : _C.textSec,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
          child: Text(label),
        ),
        const SizedBox(height: 7),
        // Input container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            // rgba(255,255,255,0.05)
            color: _C.glass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? _C.red.withValues(alpha: 0.70)
                  : isFocused
                      ? focusColor.withValues(alpha: 0.65)
                      : _C.glassBorder,
              width: isFocused ? 1.5 : 1.0,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                        color: focusColor.withValues(alpha: 0.22),
                        blurRadius: 16,
                        spreadRadius: 0),
                  ]
                : hasError
                    ? [
                        BoxShadow(
                            color: _C.red.withValues(alpha: 0.14),
                            blurRadius: 10,
                            spreadRadius: 0),
                      ]
                    : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            style: const TextStyle(
              color: _C.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.20),
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
              prefixIcon: Icon(icon,
                  color: isFocused ? focusColor : _C.textSec, size: 18),
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10), child: suffix)
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        // Error message
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Row(children: [
              const Icon(Icons.error_outline_rounded, size: 12, color: _C.red),
              const SizedBox(width: 4),
              Text(error,
                  style: const TextStyle(
                      color: _C.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
      ],
    );
  }
}
