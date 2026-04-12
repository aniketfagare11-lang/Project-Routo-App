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

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
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
          child: Column(children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionHeader('Recent'),
                  const SizedBox(height: 16),
                  _buildNotificationCard('Order Out for Delivery', 'Your Route RT-4029 is out for delivery. ETA is 10:30 AM.', '2 mins ago', Icons.local_shipping_rounded, isUnread: true, color: _C.accentB),
                  const SizedBox(height: 16),
                  _buildNotificationCard('Payment Successful', 'Your recent wallet top-up of \$50 was successful.', '1 hour ago', Icons.account_balance_wallet_rounded, isUnread: true, color: _C.accentA),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Yesterday'),
                  const SizedBox(height: 16),
                  _buildNotificationCard('Route Completed', 'You successfully completed Route RT-4028.', 'Yesterday', Icons.check_circle_rounded, color: _C.accentC),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            _buildClearAllButton(),
          ]),
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
      title: const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
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
          _orb(x: 0.10 + 0.05 * math.cos(t),       y: 0.20 + 0.08 * math.sin(t),       size: 300, color: _C.accentA.withValues(alpha: 0.08)),
          _orb(x: 0.88 + 0.06 * math.cos(t + 2.1), y: 0.35 + 0.07 * math.sin(t + 2.1), size: 240, color: _C.accentB.withValues(alpha: 0.07)),
          _orb(x: 0.45 + 0.07 * math.cos(t + 4.2), y: 0.78 + 0.05 * math.sin(t + 4.2), size: 180, color: _C.accentC.withValues(alpha: 0.06)),
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

  Widget _buildNotificationCard(String title, String body, String time, IconData icon, {bool isUnread = false, required Color color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(color: _C.glass, borderRadius: BorderRadius.circular(24), border: Border.all(color: isUnread ? color.withValues(alpha: 0.4) : _C.glassBorder)),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: TextStyle(fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700, fontSize: 16, color: Colors.white))),
                        if (isUnread) Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(body, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Text(time, style: TextStyle(fontSize: 11, color: _C.textSec.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearAllButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            color: Colors.white.withValues(alpha: 0.03),
          ),
          child: const Center(
            child: Text('Mark All as Read', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
