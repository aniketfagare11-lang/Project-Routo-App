import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSendingOtp = false;
  String? _verificationId;
  dynamic _webConfirmationResult;

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

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

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
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _sendOtp() async {
    String phone = _mobileController.text.trim();
    if (phone.isEmpty) {
      _showError('Please enter a mobile number first.');
      return;
    }

    if (!phone.startsWith('+')) {
      phone = '+91$phone';
    }

    setState(() => _isSendingOtp = true);
    try {
      if (kIsWeb) {
        RecaptchaVerifier verifier = RecaptchaVerifier(
          auth: FirebaseAuthPlatform.instance,
          container: 'recaptcha-container',
          size: RecaptchaVerifierSize.compact,
          theme: RecaptchaVerifierTheme.light,
        );
        _webConfirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(phone, verifier);
        _showSuccess('OTP Sent to $phone');
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (PhoneAuthCredential credential) {
            if (credential.smsCode != null) {
              _otpController.text = credential.smsCode!;
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            _showError(e.message ?? 'Verification failed');
          },
          codeSent: (String verificationId, int? resendToken) {
            if (mounted) {
              setState(() => _verificationId = verificationId);
              _showSuccess('OTP Sent to $phone');
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
      _showError('Failed to send OTP. Try again.');
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    final otp = _otpController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _showError('Please fill in all required email/password fields.');
      return;
    }

    if ((_verificationId != null || _webConfirmationResult != null) && otp.isEmpty) {
      _showError('Please enter the OTP sent to your mobile.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCred.user;
      if (user != null) {
        await user.updateDisplayName(name);
        
        if (otp.isNotEmpty && (_verificationId != null || _webConfirmationResult != null)) {
          try {
            PhoneAuthCredential credential;
            if (kIsWeb && _webConfirmationResult != null) {
              credential = PhoneAuthProvider.credential(
                verificationId: _webConfirmationResult.verificationId,
                smsCode: otp,
              );
            } else {
              credential = PhoneAuthProvider.credential(
                verificationId: _verificationId!,
                smsCode: otp,
              );
            }
            await user.linkWithCredential(credential);
          } on FirebaseAuthException catch (e) {
            if (e.code == 'invalid-verification-code') {
              _showError('Invalid OTP');
            } else {
              _showError(e.message ?? 'Phone verification failed.');
            }
          }
        }
      }
      
      _showSuccess('Signup Successful');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'User already exists. Please login.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'weak-password':
          message = 'Please enter a stronger password.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Please try again later.';
          break;
        case 'invalid-verification-code':
          message = 'Invalid OTP';
          break;
        default:
          message = e.message ?? 'Signup failed. Please try again.';
      }
      _showError(message);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D47A1), // Deep blue
                Color(0xFF1565C0), // Blue
                Color(0xFF1976D2), // Medium blue
                Color(0xFFE65100), // Deep orange
                Color(0xFFFF6F00), // Amber orange
              ],
              stops: [0.0, 0.25, 0.45, 0.78, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Decorative background circles
                Positioned(
                  top: -60,
                  right: -60,
                  child: _buildDecoCircle(200, Colors.white.withValues(alpha: 0.04)),
                ),
                Positioned(
                  top: 80,
                  left: -80,
                  child: _buildDecoCircle(160, Colors.white.withValues(alpha: 0.03)),
                ),
                Positioned(
                  bottom: 100,
                  right: -40,
                  child: _buildDecoCircle(120, Colors.white.withValues(alpha: 0.04)),
                ),
                // Animated route path decoration
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomPaint(
                    painter: SignupRouteDotsPainter(),
                  ),
                ),
                // Main content
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
                          // Logo section
                          SlideTransition(
                            position: _logoSlide,
                            child: _buildLogoSection(),
                          ),
                          const SizedBox(height: 12),
                          // Tagline
                          ScaleTransition(
                            scale: _taglineScale,
                            child: _buildTagline(),
                          ),
                          const SizedBox(height: 44),
                          // Signup card
                          SlideTransition(
                            position: _cardSlide,
                            child: _buildSignupCard(),
                          ),
                          const SizedBox(height: 24),
                          // Footer
                          FadeTransition(
                            opacity: _fadeAnim,
                            child: _buildFooter(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) =>
              Transform.scale(scale: _pulseAnim.value, child: child),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFFFF6F00).withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 4),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/routo_logo.png',
                  fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'ROUTO',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [
              Shadow(
                  color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rocket_launch_rounded, color: Color(0xFFFFCC80), size: 16),
          SizedBox(width: 6),
          Text(
            'Join the Journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(-4, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D1B2A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sign up to get started',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A97A6),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),
            
            _buildTextField(
              controller: _nameController,
              hint: 'Full Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _emailController,
              hint: 'Email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _mobileController,
              hint: 'Mobile Number',
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              suffix: TextButton(
                onPressed: _isSendingOtp ? null : _sendOtp,
                child: _isSendingOtp 
                   ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                   : const Text('Send OTP', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _otpController,
              hint: 'OTP Verification Code',
              icon: Icons.message_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
            ),
            const SizedBox(height: 32),
            
            _buildSignupButton(),
            const SizedBox(height: 20),
            // Divider
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 0.8,
                    color: const Color(0xFFE8ECF0),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or continue with',
                    style: TextStyle(
                      color: Color(0xFFB0BAC5),
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 0.8,
                    color: const Color(0xFFE8ECF0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Google Social button
            _buildGoogleButton(),
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
    Widget? suffix,
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
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF0D1B2A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFB0BAC5),
            fontWeight: FontWeight.w400,
            fontSize: 14.5,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, color: const Color(0xFF8A97A6), size: 20),
          ),
          suffixIcon: suffix ?? 
              (isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF8A97A6),
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSignup,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFFE65100)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
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
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F2), shape: BoxShape.circle),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/google.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => const Text('G',
                      style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Continue with Google',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.15)),
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
        const Text(
          "Already have an account? ",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class SignupRouteDotsPainter extends CustomPainter {
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
      Offset(size.width * 0.88, size.height * 0.08),
      Offset(size.width * 0.75, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.28),
      Offset(size.width * 0.70, size.height * 0.35),
      Offset(size.width * 0.12, size.height * 0.72),
      Offset(size.width * 0.22, size.height * 0.82),
      Offset(size.width * 0.08, size.height * 0.90),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      const dashLength = 6.0;
      const gapLength = 5.0;
      final dx = points[i + 1].dx - points[i].dx;
      final dy = points[i + 1].dy - points[i].dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      final nx = dx / dist;
      final ny = dy / dist;
      double traveled = 0;
      bool drawing = true;
      while (traveled < dist) {
        final segEnd =
            math.min(traveled + (drawing ? dashLength : gapLength), dist);
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
