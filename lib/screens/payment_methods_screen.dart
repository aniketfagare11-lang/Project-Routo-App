import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class _C {
  static const bg1        = Color(0xFF020617);
  static const glass      = Color(0x14FFFFFF);
  static const glassBorder= Color(0x20FFFFFF);
  static const accentA    = Color(0xFF3B82F6);
  static const accentB    = Color(0xFFF97316);
  static const accentC    = Color(0xFF8B5CF6);
  static const textSec    = Color(0xFF64748B);
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg1,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFAB(),
      body: Stack(children: [
        _buildBackground(),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 10),
              _buildSectionHeader('Primary Card'),
              const SizedBox(height: 16),
              _buildCreditCardVisual(),
              const SizedBox(height: 32),
              _buildSectionHeader('Other Methods'),
              const SizedBox(height: 16),
              _buildPaymentTile('Apple Pay', Icons.apple, _C.accentA),
              const SizedBox(height: 12),
              _buildPaymentTile('PayPal', Icons.paypal, _C.accentC),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [_C.accentA, _C.accentB]),
        boxShadow: [BoxShadow(color: _C.accentA.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: _appBarAction(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
      title: const Text('Payment Methods', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
      actions: [
        _appBarAction(icon: Icons.home_rounded, onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false)),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _appBarAction({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: _C.glass, borderRadius: BorderRadius.circular(12), border: Border.all(color: _C.glassBorder)),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _bgAnim,
      builder: (_, __) {
        final t = _bgAnim.value * 2 * math.pi;
        return Stack(children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F172A), Color(0xFF020617), Color(0xFF0C1220)]))),
          _orb(x: 0.12 + 0.05 * math.cos(t),       y: 0.15 + 0.06 * math.sin(t),       size: 280, color: _C.accentA.withValues(alpha: 0.08)),
          _orb(x: 0.85 + 0.06 * math.cos(t + 2.1), y: 0.42 + 0.08 * math.sin(t + 2.1), size: 230, color: _C.accentB.withValues(alpha: 0.07)),
          _orb(x: 0.45 + 0.07 * math.cos(t + 4.2), y: 0.72 + 0.05 * math.sin(t + 4.2), size: 190, color: _C.accentC.withValues(alpha: 0.06)),
        ]);
      },
    );
  }

  Widget _orb({required double x, required double y, required double size, required Color color}) {
    return Positioned.fill(child: Align(alignment: Alignment(x * 2 - 1, y * 2 - 1), child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])))));
  }

  Widget _buildSectionHeader(String title) {
    return Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _C.textSec, letterSpacing: 1.5));
  }

  Widget _buildCreditCardVisual() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _C.glassBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [_C.accentA.withValues(alpha: 0.2), _C.accentC.withValues(alpha: 0.1), Colors.black26],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.contactless_rounded, color: Colors.white70, size: 28),
                  Text('VISA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 1)),
                ],
              ),
              const Text('••••  ••••  ••••  4242', style: TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontWeight: FontWeight.w600)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCardLabel('CARD HOLDER', 'ALEX JOHNSON'),
                  _buildCardLabel('EXPIRES', '08/28'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardLabel(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildPaymentTile(String title, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(color: _C.glass, borderRadius: BorderRadius.circular(20), border: Border.all(color: _C.glassBorder)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 24, color: color),
            ),
            title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.3), size: 16),
          ),
        ),
      ),
    );
  }
}
