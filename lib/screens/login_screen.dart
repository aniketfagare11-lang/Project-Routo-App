import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _cardSlide;
  late Animation<double> _taglineScale;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
<<<<<<< HEAD
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
=======
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _taglineScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A3880),
                Color(0xFF1565C0),
                Color(0xFF5B3FBF),
                Color(0xFFD84315),
                Color(0xFFFF8F00),
              ],
              stops: [0.0, 0.28, 0.52, 0.78, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
<<<<<<< HEAD
                  top: -60,
                  right: -60,
                  child: _buildDecoCircle(
                      200, Colors.white.withValues(alpha: 0.04)),
                ),
                Positioned(
                  top: 80,
                  left: -80,
                  child: _buildDecoCircle(
                      160, Colors.white.withValues(alpha: 0.03)),
                ),
                Positioned(
                  bottom: 100,
                  right: -40,
                  child: _buildDecoCircle(
                      120, Colors.white.withValues(alpha: 0.04)),
=======
                  top: -60, right: -60,
                  child: _buildDecoCircle(200, Colors.white.withValues(alpha: 0.04)),
                ),
                Positioned(
                  top: 80, left: -80,
                  child: _buildDecoCircle(160, Colors.white.withValues(alpha: 0.03)),
                ),
                Positioned(
                  bottom: 100, right: -40,
                  child: _buildDecoCircle(120, Colors.white.withValues(alpha: 0.04)),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
                ),
                const Positioned.fill(
                  child: CustomPaint(painter: RouteDotsPainter()),
                ),
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 48),
<<<<<<< HEAD
                          SlideTransition(
                              position: _logoSlide, child: _buildLogoSection()),
                          const SizedBox(height: 12),
                          ScaleTransition(
                              scale: _taglineScale, child: _buildTagline()),
                          const SizedBox(height: 44),
                          SlideTransition(
                              position: _cardSlide, child: _buildLoginCard()),
                          const SizedBox(height: 24),
                          FadeTransition(
                              opacity: _fadeAnim, child: _buildFooter()),
=======
                          SlideTransition(position: _logoSlide, child: _buildLogoSection()),
                          const SizedBox(height: 12),
                          ScaleTransition(scale: _taglineScale, child: _buildTagline()),
                          const SizedBox(height: 44),
                          SlideTransition(position: _cardSlide, child: _buildLoginCard()),
                          const SizedBox(height: 24),
                          FadeTransition(opacity: _fadeAnim, child: _buildFooter()),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
                          const SizedBox(height: 32),
                        ],
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

  Widget _buildDecoCircle(double size, Color color) {
    return Container(
<<<<<<< HEAD
      width: size,
      height: size,
=======
      width: size, height: size,
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnim,
<<<<<<< HEAD
          builder: (context, child) =>
              Transform.scale(scale: _pulseAnim.value, child: child),
          child: Container(
            width: 100,
            height: 100,
=======
          builder: (context, child) => Transform.scale(scale: _pulseAnim.value, child: child),
          child: Container(
            width: 100, height: 100,
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
<<<<<<< HEAD
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
                BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.25),
                    blurRadius: 36,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/routo_logo.png',
                  fit: BoxFit.cover),
=======
                BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 24, offset: const Offset(0, 8)),
                BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.25), blurRadius: 36, offset: const Offset(0, 4)),
              ],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/routo_logo.png', fit: BoxFit.cover),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'ROUTO',
          style: TextStyle(
<<<<<<< HEAD
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [
              Shadow(
                  color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2))
            ],
=======
            fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4,
            shadows: [Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2))],
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white.withValues(alpha: 0.10),
<<<<<<< HEAD
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.0),
=======
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.0),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on_rounded, color: Color(0xFFFFD54F), size: 15),
          SizedBox(width: 5),
          Text(
            'Move Smart. Deliver Faster.',
<<<<<<< HEAD
            style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.4),
=======
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.4),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
<<<<<<< HEAD
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 16)),
          BoxShadow(
              color: const Color(0xFF1565C0).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(-4, 0)),
=======
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 40, offset: const Offset(0, 16)),
          BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(-4, 0)),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back',
<<<<<<< HEAD
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D1B2A),
                    letterSpacing: -0.5)),
            const SizedBox(height: 4),
            const Text('Sign in to your Routo account',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A97A6),
                    fontWeight: FontWeight.w400)),
            const SizedBox(height: 28),
            _buildTextField(
                controller: _emailController,
                hint: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true),
=======
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0D1B2A), letterSpacing: -0.5)),
            const SizedBox(height: 4),
            const Text('Sign in to your Routo account',
              style: TextStyle(fontSize: 14, color: Color(0xFF8A97A6), fontWeight: FontWeight.w400)),
            const SizedBox(height: 28),
            _buildTextField(controller: _emailController, hint: 'Email address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(controller: _passwordController, hint: 'Password', icon: Icons.lock_outline_rounded, isPassword: true),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
<<<<<<< HEAD
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Forgot Password?',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600)),
=======
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Forgot Password?',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
              ),
            ),
            const SizedBox(height: 24),
            _buildLoginButton(),
            const SizedBox(height: 20),
            Row(
              children: [
<<<<<<< HEAD
                Expanded(
                    child:
                        Container(height: 0.8, color: const Color(0xFFE8ECF0))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with',
                      style:
                          TextStyle(color: Color(0xFFB0BAC5), fontSize: 12.5)),
                ),
                Expanded(
                    child:
                        Container(height: 0.8, color: const Color(0xFFE8ECF0))),
=======
                Expanded(child: Container(height: 0.8, color: const Color(0xFFE8ECF0))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with', style: TextStyle(color: Color(0xFFB0BAC5), fontSize: 12.5)),
                ),
                Expanded(child: Container(height: 0.8, color: const Color(0xFFE8ECF0))),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
              ],
            ),
            const SizedBox(height: 20),
            _buildGoogleButton(),
            const SizedBox(height: 12),
            _buildPhoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
<<<<<<< HEAD
        style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: Color(0xFFB0BAC5),
              fontWeight: FontWeight.w400,
              fontSize: 14.5),
=======
        style: const TextStyle(fontSize: 15, color: Color(0xFF0D1B2A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFB0BAC5), fontWeight: FontWeight.w400, fontSize: 14.5),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, color: const Color(0xFF8A97A6), size: 20),
          ),
          suffixIcon: isPassword
              ? IconButton(
<<<<<<< HEAD
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8A97A6),
                      size: 20),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
=======
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF8A97A6), size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFFE65100)],
<<<<<<< HEAD
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8)),
=======
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
          ],
        ),
        child: Center(
          child: _isLoading
<<<<<<< HEAD
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Sign In',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
=======
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        splashColor: const Color(0xFFE8F0FE),
        highlightColor: const Color(0xFFF0F4FF),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E4EA), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
<<<<<<< HEAD
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F2), shape: BoxShape.circle),
=======
                width: 28, height: 28,
                decoration: const BoxDecoration(color: Color(0xFFF2F2F2), shape: BoxShape.circle),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/google.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => const Text('G',
<<<<<<< HEAD
                      style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
=======
                    style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.w800, fontSize: 14)),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
                ),
              ),
              const SizedBox(width: 12),
              const Text('Continue with Google',
<<<<<<< HEAD
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.15)),
=======
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), letterSpacing: 0.15)),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
<<<<<<< HEAD
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1565C0).withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6)),
=======
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.40), blurRadius: 16, offset: const Offset(0, 6)),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_android_rounded, color: Colors.white, size: 21),
              SizedBox(width: 12),
              Text('Continue with Phone',
<<<<<<< HEAD
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.1)),
=======
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.1)),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
<<<<<<< HEAD
        const Text("Don't have an account? ",
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SignupScreen())),
          child: const Text('Sign Up',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white)),
=======
        const Text("Don't have an account? ", style: TextStyle(color: Colors.white70, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
          child: const Text('Sign Up',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline, decorationColor: Colors.white)),
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
        ),
      ],
    );
  }
}

class RouteDotsPainter extends CustomPainter {
  const RouteDotsPainter();

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
      Offset(size.width * 0.12, size.height * 0.08),
      Offset(size.width * 0.25, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.28),
      Offset(size.width * 0.30, size.height * 0.35),
      Offset(size.width * 0.88, size.height * 0.72),
      Offset(size.width * 0.78, size.height * 0.82),
      Offset(size.width * 0.92, size.height * 0.90),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      const dashLength = 6.0;
      const gapLength = 5.0;
<<<<<<< HEAD
=======
      final dashLength = 6.0;
      final gapLength = 5.0;
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
      final dx = points[i + 1].dx - points[i].dx;
      final dy = points[i + 1].dy - points[i].dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      final nx = dx / dist;
      final ny = dy / dist;
      double traveled = 0;
      bool drawing = true;
      while (traveled < dist) {
<<<<<<< HEAD
        final segEnd =
            math.min(traveled + (drawing ? dashLength : gapLength), dist);
=======
        final segEnd = math.min(traveled + (drawing ? dashLength : gapLength), dist);
>>>>>>> 7b34663b5bc0b48cd95a1693aa8eac7c58dfd37a
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
