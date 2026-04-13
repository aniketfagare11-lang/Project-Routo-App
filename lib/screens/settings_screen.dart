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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
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
              _buildGroup(
                'PREFERENCES',
                [
                  _buildItem('Language', Icons.language_rounded, _C.accentA, trailing: 'English'),
                  _buildItem('Currency', Icons.payments_outlined, _C.accentC, trailing: 'USD (\$)'),
                  _buildToggle('Dark Mode', Icons.dark_mode_rounded, _C.accentB, true),
                ],
              ),
              const SizedBox(height: 24),
              _buildGroup(
                'ABOUT ROUTO',
                [
                  _buildItem('App Version', Icons.info_outline_rounded, _C.accentA, trailing: 'v2.4.1'),
                  _buildItem('Terms of Service', Icons.description_rounded, _C.accentC),
                  _buildItem('Privacy Policy', Icons.policy_rounded, _C.accentB),
                ],
              ),
              const SizedBox(height: 48),
              Center(
                child: Column(children: [
                  Text('Made with ❤️ by Routo Team',
                      style: TextStyle(color: _C.textSec.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('© 2024 Routo. All rights reserved.',
                      style: TextStyle(color: _C.textSec.withValues(alpha: 0.4), fontSize: 10)),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: _appBarAction(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
      title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
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
          _orb(x: 0.15 + 0.05 * math.cos(t),       y: 0.10 + 0.06 * math.sin(t),       size: 280, color: _C.accentA.withValues(alpha: 0.08)),
          _orb(x: 0.82 + 0.06 * math.cos(t + 2.1), y: 0.35 + 0.08 * math.sin(t + 2.1), size: 210, color: _C.accentB.withValues(alpha: 0.07)),
          _orb(x: 0.48 + 0.07 * math.cos(t + 4.2), y: 0.70 + 0.05 * math.sin(t + 4.2), size: 170, color: _C.accentC.withValues(alpha: 0.06)),
        ]);
      },
    );
  }

  Widget _orb({required double x, required double y, required double size, required Color color}) {
    return Positioned.fill(child: Align(alignment: Alignment(x * 2 - 1, y * 2 - 1), child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])))));
  }

  Widget _buildGroup(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 12, bottom: 12), child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _C.textSec, letterSpacing: 1.5))),
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(color: _C.glass, borderRadius: BorderRadius.circular(24), border: Border.all(color: _C.glassBorder)),
            child: Column(children: children),
          ),
        ),
      ),
    ]);
  }

  Widget _buildItem(String title, IconData icon, Color color, {String? trailing}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
            if (trailing != null) Text(trailing, style: const TextStyle(color: _C.textSec, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: _C.textSec.withValues(alpha: 0.5), size: 14),
          ]),
        ),
      ),
    );
  }

  Widget _buildToggle(String title, IconData icon, Color color, bool val) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
        Switch(
          value: val,
          onChanged: (_) {},
          activeThumbColor: _C.accentB,
          activeTrackColor: _C.accentB.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.white30,
          inactiveTrackColor: Colors.white12,
        ),
      ]),
    );
  }
}
