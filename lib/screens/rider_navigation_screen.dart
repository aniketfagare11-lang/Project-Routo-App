import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

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
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSec = Color(0xFF64748B);
  static Color blueGlow(double a) => accentA.withValues(alpha: a);
  static Color orangeGlow(double a) => accentB.withValues(alpha: a);
  static Color greenGlow(double a) => green.withValues(alpha: a);
}

// ─────────────────────────────────────────────────────────────────────────────
//  DELIVERY STEP ENUM
// ─────────────────────────────────────────────────────────────────────────────
enum _DeliveryStep { initial, headingToPickup, pickedUp, delivered }

// ─────────────────────────────────────────────────────────────────────────────
//  RIDER NAVIGATION SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class RiderNavigationScreen extends StatefulWidget {
  final String parcelId;
  final String pickupAddress;
  final String dropAddress;
  final String earnings;

  const RiderNavigationScreen({
    super.key,
    required this.parcelId,
    required this.pickupAddress,
    required this.dropAddress,
    required this.earnings,
  });

  @override
  State<RiderNavigationScreen> createState() => _RiderNavigationScreenState();
}

class _RiderNavigationScreenState extends State<RiderNavigationScreen>
    with TickerProviderStateMixin {
  _DeliveryStep _step = _DeliveryStep.initial;
  bool _showDeliveredOverlay = false;

  late AnimationController _bgCtrl;
  late AnimationController _vehicleCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _overlayCtrl;
  late AnimationController _btnCtrl;

  late Animation<double> _bgAnim;
  late Animation<double> _vehicleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _progressAnim;
  late Animation<double> _overlayScale;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 16))
      ..repeat();
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.linear);

    _vehicleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _vehicleAnim =
        CurvedAnimation(parent: _vehicleCtrl, curve: Curves.linear);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _progressAnim =
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic);

    _overlayCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _overlayScale =
        CurvedAnimation(parent: _overlayCtrl, curve: Curves.elasticOut);

    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _btnScale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _vehicleCtrl.dispose();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    _overlayCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  double get _progressValue {
    switch (_step) {
      case _DeliveryStep.initial:
        return 0.0;
      case _DeliveryStep.headingToPickup:
        return 0.33;
      case _DeliveryStep.pickedUp:
        return 0.66;
      case _DeliveryStep.delivered:
        return 1.0;
    }
  }

  String get _etaText {
    switch (_step) {
      case _DeliveryStep.initial:
        return 'Tap "Start Pickup" to begin';
      case _DeliveryStep.headingToPickup:
        return 'Heading to pickup • ~12 min';
      case _DeliveryStep.pickedUp:
        return 'Parcel picked up • ~45 min to delivery';
      case _DeliveryStep.delivered:
        return 'Delivery completed! 🎉';
    }
  }

  String get _actionLabel {
    switch (_step) {
      case _DeliveryStep.initial:
        return '🏁  Start Pickup';
      case _DeliveryStep.headingToPickup:
        return '📦  Mark as Picked Up';
      case _DeliveryStep.pickedUp:
        return '✅  Mark as Delivered';
      case _DeliveryStep.delivered:
        return '🎉  Delivery Complete';
    }
  }

  List<Color> get _actionGradient {
    switch (_step) {
      case _DeliveryStep.initial:
        return [_C.accentA, _C.accentC];
      case _DeliveryStep.headingToPickup:
        return [_C.accentB, const Color(0xFFEF4444)];
      case _DeliveryStep.pickedUp:
        return [const Color(0xFF059669), _C.green];
      case _DeliveryStep.delivered:
        return [const Color(0xFF059669), _C.green];
    }
  }

  Future<void> _advanceStep() async {
    if (_step == _DeliveryStep.delivered) return;
    HapticFeedback.mediumImpact();
    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    setState(() {
      switch (_step) {
        case _DeliveryStep.initial:
          _step = _DeliveryStep.headingToPickup;
          break;
        case _DeliveryStep.headingToPickup:
          _step = _DeliveryStep.pickedUp;
          break;
        case _DeliveryStep.pickedUp:
          _step = _DeliveryStep.delivered;
          _showDeliveredOverlay = true;
          break;
        case _DeliveryStep.delivered:
          break;
      }
    });

    _progressCtrl.animateTo(_progressValue,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic);

    if (_step == _DeliveryStep.delivered) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      _overlayCtrl.forward();
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, a, b) => const HomeScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg1,
      body: Stack(children: [
        _buildBackground(),
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildMapArea()),
              _buildBottomPanel(),
            ],
          ),
        ),
        if (_showDeliveredOverlay) _buildDeliveredOverlay(),
      ]),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _C.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.glassBorder),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _C.glass,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.glassBorder),
                ),
                child: Row(children: [
                  const Icon(Icons.navigation_rounded,
                      color: _C.accentA, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _step == _DeliveryStep.pickedUp ||
                              _step == _DeliveryStep.delivered
                          ? widget.dropAddress
                          : widget.pickupAddress,
                      style: const TextStyle(
                          color: _C.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _C.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.green.withValues(alpha: 0.35)),
          ),
          child: Text(widget.earnings,
              style: const TextStyle(
                  color: _C.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ),
      ]),
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
              x: 0.15 + 0.08 * math.cos(t),
              y: 0.25 + 0.05 * math.sin(t),
              size: 280,
              color: _C.accentA.withValues(alpha: 0.07)),
          _orb(
              x: 0.80 + 0.05 * math.cos(t + 2.1),
              y: 0.55 + 0.06 * math.sin(t + 2.1),
              size: 220,
              color: _C.accentB.withValues(alpha: 0.06)),
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

  Widget _buildMapArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _C.glassBorder),
              color: const Color(0x0AFFFFFF),
            ),
            child: AnimatedBuilder(
              animation: Listenable.merge([_vehicleAnim, _pulseAnim]),
              builder: (_, __) => CustomPaint(
                painter: _NavigationMapPainter(
                  vehicleProgress: _vehicleAnim.value,
                  deliveryStep: _step,
                  pulseValue: _pulseAnim.value,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step badges
                      Row(children: [
                        _stepBadge('1', 'Pickup', _C.accentA,
                            _step.index >= 1),
                        const SizedBox(width: 8),
                        _stepConnector(),
                        const SizedBox(width: 8),
                        _stepBadge('2', 'In Transit', _C.accentC,
                            _step.index >= 2),
                        const SizedBox(width: 8),
                        _stepConnector(),
                        const SizedBox(width: 8),
                        _stepBadge('3', 'Delivered', _C.green,
                            _step.index >= 3),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBadge(
      String num, String label, Color color, bool active) {
    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? color : _C.surfaceEl,
          border: Border.all(
              color: active ? color : _C.glassBorder,
              width: active ? 2 : 1),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1)
                ]
              : [],
        ),
        child: Center(
          child: active
              ? Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text(num,
                  style: TextStyle(
                      color: _C.textSec,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: TextStyle(
              color: active ? color : _C.textSec,
              fontSize: 9,
              fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _stepConnector() {
    return Expanded(
      child: Container(
        height: 1.5,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_C.accentA, _C.accentC],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ETA row
                Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      color: _C.accentA, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_etaText,
                        style: const TextStyle(
                            color: _C.textSec,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500)),
                  ),
                ]),
                const SizedBox(height: 12),

                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) {
                    return Column(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: _progressAnim.value == 0.0
                              ? _progressValue
                              : _progressAnim.value,
                          minHeight: 6,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _step == _DeliveryStep.delivered
                                ? _C.green
                                : _C.accentA,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pickup',
                              style: TextStyle(
                                  color: _C.textSec,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500)),
                          Text('In Transit',
                              style: TextStyle(
                                  color: _C.textSec,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500)),
                          Text('Delivered',
                              style: TextStyle(
                                  color: _C.green,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ]);
                  },
                ),

                const SizedBox(height: 16),

                // Action button
                ScaleTransition(
                  scale: _btnScale,
                  child: GestureDetector(
                    onTap: _step == _DeliveryStep.delivered
                        ? null
                        : _advanceStep,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: _actionGradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  _actionGradient.first.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Center(
                        child: Text(_actionLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveredOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: ScaleTransition(
              scale: _overlayScale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1C35),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: _C.green.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                        color: _C.greenGlow(0.3),
                        blurRadius: 60,
                        spreadRadius: 4),
                  ],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Trophy icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _C.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: _C.greenGlow(0.35),
                            blurRadius: 28,
                            spreadRadius: 2)
                      ],
                    ),
                    child: const Text('🎉',
                        style: TextStyle(fontSize: 42)),
                  ),
                  const SizedBox(height: 22),
                  const Text('Parcel Delivered!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 8),
                  Text(
                    'Great job! You\'ve successfully delivered\n${widget.parcelId} to the recipient.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13.5,
                        height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // Earnings chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF064E3B), Color(0xFF065F46)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _C.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.currency_rupee_rounded,
                          color: _C.green, size: 20),
                      const SizedBox(width: 6),
                      Text('You earned ${widget.earnings}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Home button
                  GestureDetector(
                    onTap: _goHome,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                            colors: [_C.accentA, _C.accentB]),
                        boxShadow: [
                          BoxShadow(
                              color: _C.blueGlow(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: const Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.home_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Back to Home',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NAVIGATION MAP PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _NavigationMapPainter extends CustomPainter {
  final double vehicleProgress;
  final _DeliveryStep deliveryStep;
  final double pulseValue;

  _NavigationMapPainter({
    required this.vehicleProgress,
    required this.deliveryStep,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dot grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    const step = 28.0;
    for (double x = 0; x < w; x += step) {
      for (double y = 0; y < h; y += step) {
        canvas.drawCircle(Offset(x, y), 1.2, gridPaint);
      }
    }

    // Road background lanes
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 40
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPath = Path();
    roadPath.moveTo(w * 0.05, h * 0.8);
    roadPath.cubicTo(
        w * 0.25, h * 0.15, w * 0.6, h * 0.85, w * 0.95, h * 0.2);
    canvas.drawPath(roadPath, roadPaint);

    // Route path
    final metrics = roadPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final pm = metrics.first;
    final total = pm.length;

    // Completed portion
    final completedFraction = deliveryStep == _DeliveryStep.delivered
        ? 1.0
        : deliveryStep == _DeliveryStep.pickedUp
            ? 0.7
            : deliveryStep == _DeliveryStep.headingToPickup
                ? 0.35
                : 0.0;

    final routePaintDone = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (completedFraction > 0) {
      final donePath = pm.extractPath(0, total * completedFraction);
      canvas.drawPath(donePath, routePaintDone);
    }

    // Remaining path (dashed look)
    final routePaintRemaining = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (completedFraction < 1.0) {
      final remaining =
          pm.extractPath(total * completedFraction, total);
      canvas.drawPath(remaining, routePaintRemaining);
    }

    // Start pin
    final startTan = pm.getTangentForOffset(0);
    if (startTan != null) {
      _drawPin(canvas, startTan.position, const Color(0xFF3B82F6),
          pulseValue, isStart: true);
    }

    // End pin
    final endTan = pm.getTangentForOffset(total);
    if (endTan != null) {
      _drawPin(canvas, endTan.position, const Color(0xFFF97316),
          pulseValue, isStart: false);
    }

    // Vehicle marker
    final vehicleFraction = deliveryStep == _DeliveryStep.initial
        ? 0.0
        : deliveryStep == _DeliveryStep.headingToPickup
            ? vehicleProgress * 0.33
            : deliveryStep == _DeliveryStep.pickedUp
                ? 0.33 + vehicleProgress * 0.37
                : 0.70 + vehicleProgress * 0.30;

    final clampedFrac = vehicleFraction.clamp(0.0, 1.0);
    final vehicleTan =
        pm.getTangentForOffset(total * clampedFrac);
    if (vehicleTan != null) {
      _drawVehicle(canvas, vehicleTan.position);
    }
  }

  void _drawPin(
      Canvas canvas, Offset pos, Color color, double pulse,
      {required bool isStart}) {
    // Pulse ring
    final pulsePaint = Paint()
      ..color = color.withValues(alpha: 0.2 * pulse)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 22 * pulse, pulsePaint);

    // Outer ring
    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(pos, 14, outerPaint);

    // Inner fill
    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 9, innerPaint);

    // White center
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 4, centerPaint);
  }

  void _drawVehicle(Canvas canvas, Offset pos) {
    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(pos + const Offset(0, 4), 14, shadowPaint);

    // Body
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCenter(center: pos, width: 28, height: 28))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 14, bodyPaint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(pos, 14, borderPaint);

    // Bike icon — simplified with painter
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pos + const Offset(-5, 2),
        pos + const Offset(5, 2), iconPaint);
    canvas.drawLine(pos + const Offset(0, 2),
        pos + const Offset(0, -4), iconPaint);
  }

  @override
  bool shouldRepaint(_NavigationMapPainter old) =>
      old.vehicleProgress != vehicleProgress ||
      old.deliveryStep != deliveryStep ||
      old.pulseValue != pulseValue;
}
