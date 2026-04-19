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
}

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> with TickerProviderStateMixin {
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
              _buildAddressCard('Home', '123 Main Street, Apt 4B\nNew York, NY 10001', Icons.home_rounded, isDefault: true, color: _C.accentA),
              const SizedBox(height: 16),
              _buildAddressCard('Work', '456 Tech Avenue, Floor 10\nSan Francisco, CA 94105', Icons.work_rounded, color: _C.accentC),
              const SizedBox(height: 16),
              _buildAddressCard('Other', '789 Sunset Boulevard\nLos Angeles, CA 90028', Icons.location_on_rounded, color: _C.accentB),
              const SizedBox(height: 100), // Bottom padding for FAB
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
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Add New Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: _appBarAction(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
      title: const Text('Saved Addresses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
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
          _orb(x: 0.15 + 0.05 * math.cos(t),       y: 0.12 + 0.06 * math.sin(t),       size: 270, color: _C.accentA.withValues(alpha: 0.08)),
          _orb(x: 0.82 + 0.06 * math.cos(t + 2.1), y: 0.38 + 0.08 * math.sin(t + 2.1), size: 220, color: _C.accentB.withValues(alpha: 0.07)),
          _orb(x: 0.52 + 0.07 * math.cos(t + 4.2), y: 0.75 + 0.05 * math.sin(t + 4.2), size: 180, color: _C.accentC.withValues(alpha: 0.06)),
        ]);
      },
    );
  }

  Widget _orb({required double x, required double y, required double size, required Color color}) {
    return Positioned.fill(child: Align(alignment: Alignment(x * 2 - 1, y * 2 - 1), child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])))));
  }

  Widget _buildAddressCard(String title, String address, IconData icon, {bool isDefault = false, required Color color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(color: _C.glass, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDefault ? color.withValues(alpha: 0.4) : _C.glassBorder)),
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: _C.accentB.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: const Text('DEFAULT', style: TextStyle(color: _C.accentB, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(address, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              _popMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popMenu() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.more_vert_rounded, color: _C.textSec, size: 18),
    );
  }
}
