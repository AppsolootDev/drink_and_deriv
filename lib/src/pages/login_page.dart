import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'admin_landing_page.dart';
import 'otp_page.dart';
import '../db/db_helper.dart';

enum LoginSection { login, signup, forgotPassword }

class LoginPage extends StatefulWidget {
  final bool isDatabaseConnected;
  const LoginPage({super.key, this.isDatabaseConnected = true});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // --- Splash State ---
  late AnimationController _splashController;
  late Animation<double> _spinAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _glossyFadeAnimation;
  late Animation<Offset> _loginItemsSlideAnimation;
  
  bool _isSplashDone = false;
  bool _isDatabaseConnected = false;

  // --- Login State ---
  LoginSection _currentSection = LoginSection.login;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isDatabaseConnected = widget.isDatabaseConnected;

    _splashController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _spinAnimation = Tween<double>(begin: 0, end: 4 * math.pi).animate(
      CurvedAnimation(parent: _splashController, curve: const Interval(0.0, 0.6, curve: Curves.easeInOutSine))
    );

    _logoFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _splashController, curve: const Interval(0.6, 0.8, curve: Curves.easeIn))
    );

    _glossyFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _splashController, curve: const Interval(0.7, 0.9, curve: Curves.easeIn))
    );

    _loginItemsSlideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _splashController, curve: const Interval(0.8, 1.0, curve: Curves.easeOut))
    );

    _splashController.forward().then((_) {
      if (mounted) setState(() => _isSplashDone = true);
    });

    _connectToDatabase();
  }

  Future<void> _connectToDatabase() async {
    try {
      final db = DatabaseService();
      await db.connect();
      if (mounted) setState(() => _isDatabaseConnected = true);
    } catch (e) {
      debugPrint('Localhost DB connection failed: $e');
    }
  }

  @override
  void dispose() {
    _splashController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connecting to $provider...')));
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const OtpPage(destination: 'your social account', isTutorial: true)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSplashDone ? const Text('Welcome') : null,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: (_isSplashDone && _currentSection != LoginSection.login) 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _currentSection = LoginSection.login),
            )
          : null,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(child: Image.asset('assets/background_splash.png', fit: BoxFit.cover)),
          
          // White Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white.withOpacity(0.8), Colors.white],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // --- SPLASH LAYER ---
          if (!_isSplashDone)
            Center(
              child: FadeTransition(
                opacity: _logoFadeAnimation,
                child: AnimatedBuilder(
                  animation: _spinAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _spinAnimation.value,
                      child: Container(
                        width: 150, height: 150,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [Colors.green, Colors.red, Colors.green],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 130, height: 130,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: ClipOval(
                              child: Transform.rotate(
                                angle: -_spinAnimation.value,
                                child: Image.asset('assets/images/deriv.png', fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // --- LOGIN LAYER ---
          FadeTransition(
            opacity: _glossyFadeAnimation,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: SlideTransition(
                    position: _loginItemsSlideAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildCurrentSection(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case LoginSection.signup: return _buildSignupSection();
      case LoginSection.forgotPassword: return _buildForgotPasswordSection();
      case LoginSection.login:
      default: return _buildLoginSection();
    }
  }

  Widget _buildLoginSection() {
    return Column(
      key: const ValueKey('login'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        AnimatedTextField(controller: _emailController, label: 'Username or Email', icon: Icons.person_outline, isEnabled: _isDatabaseConnected),
        const SizedBox(height: 20),
        AnimatedTextField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, isObscure: true, isEnabled: _isDatabaseConnected),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isDatabaseConnected ? () => setState(() => _currentSection = LoginSection.forgotPassword) : null,
            child: const Text('Forgot Password?'),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: _isDatabaseConnected ? _performLogin : null,
          child: const Text('Login'),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            TextButton(
              onPressed: _isDatabaseConnected ? () => setState(() => _currentSection = LoginSection.signup) : null,
              child: const Text('Sign Up'),
            ),
          ],
        ),
        if (_isDatabaseConnected) _buildSocialLogin(),
        const SizedBox(height: 30),
        const Divider(),
        _buildAdminSection(),
      ],
    );
  }

  Widget _buildSignupSection() {
    return Column(
      key: const ValueKey('signup'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Create Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        AnimatedTextField(controller: _fullNameController, label: 'Full Name', icon: Icons.person_outline),
        const SizedBox(height: 16),
        AnimatedTextField(controller: _emailController, label: 'Email Address', icon: Icons.email_outlined),
        const SizedBox(height: 16),
        AnimatedTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_outlined),
        const SizedBox(height: 16),
        AnimatedTextField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, isObscure: true),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OtpPage(destination: 'your email', isTutorial: true))),
          child: const Text('Sign Up'),
        ),
        TextButton(onPressed: () => setState(() => _currentSection = LoginSection.login), child: const Text('Already have an account? Login')),
      ],
    );
  }

  Widget _buildForgotPasswordSection() {
    return Column(
      key: const ValueKey('forgot'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset, size: 60, color: Colors.orange),
        const SizedBox(height: 16),
        const Text('Forgot Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text('Enter your email to receive a reset link.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),
        AnimatedTextField(controller: _forgotEmailController, label: 'Email Address', icon: Icons.email_outlined),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent!')));
            setState(() => _currentSection = LoginSection.login);
          },
          child: const Text('Send Reset Link'),
        ),
        TextButton(onPressed: () => setState(() => _currentSection = LoginSection.login), child: const Text('Back to Login')),
      ],
    );
  }

  void _performLogin() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => OtpPage(destination: _emailController.text, isTutorial: true)));
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR LOGIN WITH')), Expanded(child: Divider())]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _SocialButton(icon: Icons.close, color: Colors.black, onTap: () => _handleSocialLogin('X')),
          _SocialButton(icon: Icons.facebook, color: const Color(0xFF1877F2), onTap: () => _handleSocialLogin('Facebook')),
          _SocialButton(icon: Icons.business, color: const Color(0xFF0A66C2), onTap: () => _handleSocialLogin('LinkedIn')),
        ]),
      ],
    );
  }

  Widget _buildAdminSection() {
    return Column(
      children: [
        const Text('TEST & ADMIN SECTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _AdminQuickButton(icon: Icons.account_circle, label: 'User', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OtpPage(destination: 'test@user.com', isTutorial: true)))),
          const SizedBox(width: 40),
          _AdminQuickButton(icon: Icons.admin_panel_settings, label: 'Admin', color: Colors.blue, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminLandingPage()))),
        ]),
      ],
    );
  }
}

class _AdminQuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _AdminQuickButton({required this.icon, required this.label, this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Column(children: [IconButton(icon: Icon(icon, size: 40, color: color), onPressed: onTap), Text(label, style: const TextStyle(fontSize: 10))]);
  }
}

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isObscure;
  final bool isEnabled;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isObscure = false,
    this.isEnabled = true,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> with TickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _focusAnimation = CurvedAnimation(parent: _focusController, curve: Curves.easeInOut);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.isObscure,
          enabled: widget.isEnabled,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        Stack(
          children: [
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
            Center(
              child: AnimatedBuilder(
                animation: _focusAnimation,
                builder: (context, child) {
                  return Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * _focusAnimation.value,
                    color: Theme.of(context).primaryColor,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.5),
        ),
        child: Icon(icon, color: onTap == null ? Colors.grey : color, size: 30),
      ),
    );
  }
}
