import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS — consistent with ProfileScreen
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const bg0        = Color(0xFF0F172A);
  static const bg1        = Color(0xFF020617);
  static const glass      = Color(0x14FFFFFF);
  static const glassBorder= Color(0x20FFFFFF);
  static const surfaceEl  = Color(0xFF131F38);

  static const accentA = Color(0xFF3B82F6); // blue
  static const accentB = Color(0xFFF97316); // orange
  static const accentC = Color(0xFF8B5CF6); // purple

  static const textSec     = Color(0xFF64748B);

  static Color blueGlow(double a)   => accentA.withValues(alpha: a);
  static Color orangeGlow(double a) => accentB.withValues(alpha: a);
  static Color purpleGlow(double a) => accentC.withValues(alpha: a);
}

// ─────────────────────────────────────────────────────────────────────────────
//  PERSONAL DETAILS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen>
    with TickerProviderStateMixin {

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  User? _currentUser;

  late AnimationController _fadeCtrl;
  late AnimationController _bgCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _bgAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _bgCtrl   = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _bgAnim   = CurvedAnimation(parent: _bgCtrl,    curve: Curves.linear);

    _loadUserData();
    _fadeCtrl.forward();
  }

  void _loadUserData() {
    _currentUser = FirebaseAuth.instance.currentUser;
    _nameCtrl = TextEditingController(text: _currentUser?.displayName ?? 'User');
    _emailCtrl = TextEditingController(text: _currentUser?.email ?? 'No email');
    _phoneCtrl = TextEditingController(text: _currentUser?.phoneNumber ?? 'Not provided');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _fadeCtrl.dispose(); _bgCtrl.dispose();
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
        FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
                const SizedBox(height: 20),
                _buildAvatarSection(),
                const SizedBox(height: 32),
                _buildInputSection(),
                const SizedBox(height: 40),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ]),
            ),
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
      leading: _appBarAction(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.of(context).pop(),
      ),
      title: const Text('Personal Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
      actions: [
        _appBarAction(
          icon: Icons.home_rounded,
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _appBarAction({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _C.glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.glassBorder),
        ),
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF020617), Color(0xFF0C1220)],
              ),
            ),
          ),
          _orb(x: 0.12 + 0.05 * math.cos(t),       y: 0.15 + 0.08 * math.sin(t),       size: 260, color: _C.blueGlow(0.08)),
          _orb(x: 0.85 + 0.04 * math.cos(t + 2.1), y: 0.40 + 0.10 * math.sin(t + 2.1), size: 200, color: _C.orangeGlow(0.07)),
          _orb(x: 0.45 + 0.06 * math.cos(t + 4.2), y: 0.75 + 0.05 * math.sin(t + 4.2), size: 180, color: _C.purpleGlow(0.06)),
        ]);
      },
    );
  }

  Widget _orb({required double x, required double y, required double size, required Color color}) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment(x * 2 - 1, y * 2 - 1),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, Colors.transparent]),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(alignment: Alignment.bottomRight, children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _C.accentA.withValues(alpha: 0.3), width: 3),
            gradient: LinearGradient(colors: [_C.blueGlow(0.2), Colors.transparent]),
          ),
          padding: const EdgeInsets.all(6),
          child: const CircleAvatar(
            backgroundColor: _C.surfaceEl,
            child: Icon(Icons.person_rounded, size: 60, color: _C.textSec),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_C.accentA, _C.accentB]),
            shape: BoxShape.circle,
            border: Border.all(color: _C.bg0, width: 2.5),
            boxShadow: [BoxShadow(color: _C.blueGlow(0.4), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
        ),
      ]),
    );
  }

  Widget _buildInputSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _C.glassBorder),
            color: _C.glass,
          ),
          child: Column(children: [
            _buildInput(_nameCtrl, 'Full Name', Icons.person_outline_rounded, _C.accentA),
            const SizedBox(height: 20),
            _buildInput(_emailCtrl, 'Email Address', Icons.alternate_email_rounded, _C.accentC),
            const SizedBox(height: 20),
            _buildInput(_phoneCtrl, 'Phone Number', Icons.phone_android_rounded, _C.accentB),
          ]),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: const TextStyle(color: _C.textSec, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: _C.surfaceEl,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.glassBorder),
        ),
        child: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color, size: 18),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    ]);
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [_C.accentA, _C.accentB]),
        boxShadow: [BoxShadow(color: _C.blueGlow(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: const Center(
        child: Text('Save Changes',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
