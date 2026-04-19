import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'rider_available_parcels_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const bg1 = Color(0xFF020617);
  static const glass = Color(0x14FFFFFF);
  static const glassBorder = Color(0x20FFFFFF);
  static const surfaceEl = Color(0xFF131F38);
  static const accentA = Color(0xFF3B82F6);
  static const accentB = Color(0xFFF97316);
  static const accentC = Color(0xFF8B5CF6);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSec = Color(0xFF64748B);
  static Color blueGlow(double a) => accentA.withValues(alpha: a);
  static Color orangeGlow(double a) => accentB.withValues(alpha: a);
  static Color greenGlow(double a) => green.withValues(alpha: a);
}

// ─────────────────────────────────────────────────────────────────────────────
//  RIDER ROUTE SELECTION SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class RiderRouteSelectionScreen extends StatefulWidget {
  const RiderRouteSelectionScreen({super.key});

  @override
  State<RiderRouteSelectionScreen> createState() =>
      _RiderRouteSelectionScreenState();
}

class _RiderRouteSelectionScreenState extends State<RiderRouteSelectionScreen>
    with TickerProviderStateMixin {
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _startFocus = FocusNode();
  final _endFocus = FocusNode();

  bool _isFetchingGps = false;
  bool _routeReady = false;
  bool _isSearching = false;

  String? _startError;
  String? _endError;

  late AnimationController _bgCtrl;
  late AnimationController _entryCtrl;
  late AnimationController _mapCtrl;
  late Animation<double> _bgAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _mapAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 16))
      ..repeat();
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.linear);

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entryCtrl, curve: Curves.easeOutCubic));

    _mapCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _mapAnim = CurvedAnimation(parent: _mapCtrl, curve: Curves.linear);

    _entryCtrl.forward();

    for (final fn in [_startFocus, _endFocus]) {
      fn.addListener(() => setState(() {}));
    }
    _startCtrl.addListener(_onFieldChanged);
    _endCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final ready = _startCtrl.text.trim().isNotEmpty &&
        _endCtrl.text.trim().isNotEmpty;
    if (ready != _routeReady) setState(() => _routeReady = ready);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entryCtrl.dispose();
    _mapCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _startFocus.dispose();
    _endFocus.dispose();
    super.dispose();
  }

  Future<void> _fetchGps() async {
    setState(() => _isFetchingGps = true);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isFetchingGps = false;
        _startCtrl.text = 'Pune, Maharashtra';
        _startError = null;
      });
    }
  }

  bool _validate() {
    setState(() {
      _startError = _startCtrl.text.trim().isEmpty
          ? 'Enter your start location'
          : null;
      _endError = _endCtrl.text.trim().isEmpty
          ? 'Enter your destination'
          : null;
    });
    return _startError == null && _endError == null;
  }

  Future<void> _findParcels() async {
    if (!_validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSearching = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() => _isSearching = false);
      Navigator.of(context).push(_slideRoute(RiderAvailableParcelsScreen(
        fromLocation: _startCtrl.text,
        toLocation: _endCtrl.text,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg1,
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildHeroHeader(),
                    const SizedBox(height: 24),
                    _buildMapPreview(),
                    const SizedBox(height: 20),
                    _buildRouteCard(),
                    const SizedBox(height: 16),
                    if (_routeReady) _buildRouteInfoChips(),
                    const SizedBox(height: 24),
                    _buildFindButton(),
                    const SizedBox(height: 16),
                    _buildTipsCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _bgAnim,
      builder: (_, __) {
        final t = _bgAnim.value * 2 * math.pi;
        return Stack(children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF020617),
                  Color(0xFF0C1220)
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          _orb(
              x: 0.12 + 0.07 * math.cos(t),
              y: 0.10 + 0.05 * math.sin(t),
              size: 260,
              color: _C.accentB.withValues(alpha: 0.08)),
          _orb(
              x: 0.82 + 0.05 * math.cos(t + 2.0),
              y: 0.32 + 0.06 * math.sin(t + 2.0),
              size: 200,
              color: _C.accentA.withValues(alpha: 0.07)),
          _orb(
              x: 0.45 + 0.06 * math.cos(t + 4.1),
              y: 0.72 + 0.04 * math.sin(t + 4.1),
              size: 170,
              color: _C.accentC.withValues(alpha: 0.06)),
        ]);
      },
    );
  }

  Widget _orb(
      {required double x,
      required double y,
      required double size,
      required Color color}) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment(x * 2 - 1, y * 2 - 1),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, Colors.transparent]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Row(children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [_C.accentB, _C.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: _C.orangeGlow(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: const Center(child: Text('🚚', style: TextStyle(fontSize: 24))),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [_C.textPrimary, Color(0xFFFED7AA)],
            ).createShader(b),
            child: const Text('Select Your Route',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 3),
          const Text('Enter route to find parcels along the way',
              style: TextStyle(
                  fontSize: 13,
                  color: _C.textSec,
                  fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    ]);
  }

  Widget _buildMapPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _C.glassBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _C.accentB.withValues(alpha: 0.07),
                Colors.transparent,
              ],
            ),
          ),
          child: AnimatedBuilder(
            animation: _mapAnim,
            builder: (_, __) => CustomPaint(
              painter: _RoutePreviewPainter(
                progress: _mapAnim.value,
                hasRoute: _routeReady,
              ),
              child: Center(
                child: !_routeReady
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined,
                              color: _C.textSec.withValues(alpha: 0.5),
                              size: 36),
                          const SizedBox(height: 8),
                          Text('Enter locations to preview route',
                              style: TextStyle(
                                  color: _C.textSec.withValues(alpha: 0.6),
                                  fontSize: 12.5)),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _C.green.withValues(alpha: 0.4)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: _C.green),
                              ),
                              const SizedBox(width: 6),
                              const Text('Route Active',
                                  style: TextStyle(
                                      color: _C.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ]),
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

  Widget _buildRouteCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _C.glassBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _C.accentA.withValues(alpha: 0.07),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _C.accentA.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _C.accentA.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.route_rounded,
                    color: _C.accentA, size: 16),
              ),
              const SizedBox(width: 12),
              const Text('Your Route',
                  style: TextStyle(
                      color: _C.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 20),
            _buildLocationInput(
              controller: _startCtrl,
              focusNode: _startFocus,
              label: 'START LOCATION',
              hint: 'Where are you starting from?',
              icon: Icons.radio_button_checked_rounded,
              focusColor: _C.accentA,
              error: _startError,
              suffix: _isFetchingGps
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _C.accentA),
                    )
                  : GestureDetector(
                      onTap: _fetchGps,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_C.accentA, _C.accentC]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.gps_fixed_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('GPS',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 6, bottom: 6),
              child: Column(
                children: List.generate(
                    3,
                    (_) => Container(
                          width: 2,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 3),
                          decoration: BoxDecoration(
                            color: _C.textSec.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )),
              ),
            ),
            _buildLocationInput(
              controller: _endCtrl,
              focusNode: _endFocus,
              label: 'DESTINATION',
              hint: 'Where are you going?',
              icon: Icons.location_on_rounded,
              focusColor: _C.accentB,
              error: _endError,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildLocationInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required Color focusColor,
    String? error,
    Widget? suffix,
  }) {
    final focused = focusNode.hasFocus;
    final hasError = error != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: focused ? focusColor : _C.textSec,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
        child: Text(label),
      ),
      const SizedBox(height: 7),
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _C.surfaceEl,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError
                ? _C.red.withValues(alpha: 0.7)
                : focused
                    ? focusColor.withValues(alpha: 0.6)
                    : _C.glassBorder,
            width: focused ? 1.5 : 1.0,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                      color: focusColor.withValues(alpha: 0.2),
                      blurRadius: 16)
                ]
              : [],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(
              color: _C.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: _C.textSec.withValues(alpha: 0.6), fontSize: 13.5),
            prefixIcon: Icon(icon,
                color: focused ? focusColor : _C.textSec, size: 18),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 10), child: suffix)
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          ),
        ),
      ),
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
    ]);
  }

  Widget _buildRouteInfoChips() {
    return AnimatedOpacity(
      opacity: _routeReady ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Row(children: [
        _infoChip(Icons.straighten_rounded, '149 km', _C.accentA),
        const SizedBox(width: 10),
        _infoChip(Icons.access_time_rounded, '~2h 30m', _C.accentC),
        const SizedBox(width: 10),
        _infoChip(Icons.local_gas_station_rounded, '~₹180', _C.accentB),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _buildFindButton() {
    return GestureDetector(
      onTap: _isSearching ? null : _findParcels,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              _C.accentB,
              const Color(0xFFEF4444),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
                color: _C.orangeGlow(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: _isSearching
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Find Parcels on this Route',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2)),
                ]),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.glassBorder),
            color: _C.glass,
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _C.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('💡', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'The more specific your route, the better parcel matches you\'ll find along the way.',
                style: TextStyle(
                    color: _C.textSec,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    height: 1.5),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ROUTE PREVIEW PAINTER — animated dots on a road
// ─────────────────────────────────────────────────────────────────────────────
class _RoutePreviewPainter extends CustomPainter {
  final double progress;
  final bool hasRoute;
  _RoutePreviewPainter({required this.progress, required this.hasRoute});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grid background
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    const step = 24.0;
    for (double x = 0; x < w; x += step) {
      for (double y = 0; y < h; y += step) {
        canvas.drawCircle(Offset(x, y), 1.0, gridPaint);
      }
    }

    if (!hasRoute) return;

    // Route path
    final path = Path();
    path.moveTo(w * 0.08, h * 0.75);
    path.cubicTo(
        w * 0.25, h * 0.2, w * 0.6, h * 0.8, w * 0.92, h * 0.25);

    final pathPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFFF97316)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, pathPaint);

    // Dashes animation
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final pm = metrics.first;
    final total = pm.length;
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final t = ((progress + i / 5) % 1.0);
      final pos = pm.getTangentForOffset(t * total);
      if (pos != null) {
        canvas.drawCircle(pos.position, 3, dotPaint);
      }
    }

    // Start dot
    final startPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;
    final startPos = pm.getTangentForOffset(0);
    if (startPos != null) {
      canvas.drawCircle(startPos.position, 7, startPaint);
      canvas.drawCircle(
          startPos.position,
          7,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }

    // End dot
    final endPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    final endPos = pm.getTangentForOffset(total);
    if (endPos != null) {
      canvas.drawCircle(endPos.position, 7, endPaint);
      canvas.drawCircle(
          endPos.position,
          7,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_RoutePreviewPainter old) =>
      old.progress != progress || old.hasRoute != hasRoute;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SLIDE ROUTE HELPER
// ─────────────────────────────────────────────────────────────────────────────
PageRouteBuilder<T> _slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}
