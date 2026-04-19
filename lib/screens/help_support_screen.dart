import 'dart:math' as math;
import 'dart:ui';
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
  static const surfaceEl  = Color(0xFF131F38);

  static Color blueGlow(double a)   => accentA.withValues(alpha: a);
}

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with TickerProviderStateMixin {
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
      body: Stack(children: [
        _buildBackground(),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeroSection(),
              const SizedBox(height: 32),
              _buildSectionHeader('Frequently Asked Questions'),
              const SizedBox(height: 16),
              _buildFaqItem('How do I track my delivery?', 'Open the "My Routes" tab on your dashboard to see real-time updates.'),
              _buildFaqItem('What happens if I miss a location?', 'The app will automatically suggest a reroute or contact support for help.'),
              _buildFaqItem('How to update payment details?', 'Go to Profile > Payment Methods to add or edit your preferences.'),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeroSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _C.glassBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [_C.accentA.withValues(alpha: 0.15), _C.accentC.withValues(alpha: 0.1), Colors.black45],
            ),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _C.accentA.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.support_agent_rounded, size: 44, color: _C.accentA),
            ),
            const SizedBox(height: 20),
            const Text('How can we help you?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Our support team is available 24/7 for you.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [_C.accentA, _C.accentB]),
                  boxShadow: [BoxShadow(color: _C.blueGlow(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Text('Start Live Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: _appBarAction(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
      title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
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
          _orb(x: 0.12 + 0.05 * math.cos(t),       y: 0.15 + 0.06 * math.sin(t),       size: 300, color: _C.accentA.withValues(alpha: 0.08)),
          _orb(x: 0.85 + 0.06 * math.cos(t + 2.1), y: 0.40 + 0.07 * math.sin(t + 2.1), size: 240, color: _C.accentB.withValues(alpha: 0.07)),
          _orb(x: 0.48 + 0.07 * math.cos(t + 4.2), y: 0.75 + 0.05 * math.sin(t + 4.2), size: 190, color: _C.accentC.withValues(alpha: 0.06)),
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

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: _C.surfaceEl, borderRadius: BorderRadius.circular(20), border: Border.all(color: _C.glassBorder)),
      child: Theme(
        data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Text(question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          iconColor: _C.accentB,
          collapsedIconColor: _C.accentA,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(answer, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
