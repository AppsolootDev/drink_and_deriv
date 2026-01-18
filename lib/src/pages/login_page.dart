import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'admin_landing_page.dart';
import 'signup_page.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  final bool isDatabaseConnected;
  const LoginPage({super.key, this.isDatabaseConnected = true});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to $provider...')),
    );
    
    // Simulate a successful social login redirecting to OTP
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OtpPage(destination: 'your social account'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background_splash.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      AnimatedTextField(
                        controller: _emailController,
                        label: 'Username or Email',
                        icon: Icons.person_outline,
                        isEnabled: widget.isDatabaseConnected,
                      ),
                      const SizedBox(height: 20),
                      AnimatedTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isObscure: true,
                        isEnabled: widget.isDatabaseConnected,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: widget.isDatabaseConnected ? () {} : null,
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: widget.isDatabaseConnected
                            ? () {
                                if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                                  // Error feedback locally
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OtpPage(destination: _emailController.text),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: const Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: widget.isDatabaseConnected
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SignupPage()),
                                    );
                                  }
                                : null,
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                      if (widget.isDatabaseConnected) ...[
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR LOGIN WITH'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _SocialButton(
                              icon: Icons.close,
                              color: Colors.black,
                              onTap: () => _handleSocialLogin('X (Twitter)'),
                            ),
                            _SocialButton(
                              icon: Icons.facebook,
                              color: const Color(0xFF1877F2),
                              onTap: () => _handleSocialLogin('Facebook'),
                            ),
                            _SocialButton(
                              icon: Icons.business, // LinkedIn icon
                              color: const Color(0xFF0A66C2),
                              onTap: () => _handleSocialLogin('LinkedIn'),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 30),
                      const Divider(),
                      const Text(
                        'TEST & ADMIN SECTION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.account_circle, size: 40),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const OtpPage(destination: 'test@user.com'),
                                    ),
                                  );
                                },
                                tooltip: 'Fake User Login',
                              ),
                              const Text('User', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 40),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AdminLandingPage()),
                                  );
                                },
                                tooltip: 'Admin Login',
                              ),
                              const Text('Admin', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  bool _hasError = false;
  String? _errorText;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _focusAnimation = CurvedAnimation(parent: _focusController, curve: Curves.easeInOut);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    });
  }

  void triggerError(String message) {
    setState(() {
      _hasError = true;
      _errorText = message;
    });

    _shakeController.forward(from: 0).then((_) => _shakeController.reverse());

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _hasError = false;
          _errorText = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusController.dispose();
    _shakeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final double offset = (0.5 - (0.5 - _shakeController.value).abs()) * 20;
            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: TextField(
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
                    color: _hasError ? Colors.red : Theme.of(context).primaryColor,
                  );
                },
              ),
            ),
          ],
        ),
        if (_hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorText ?? '',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
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
