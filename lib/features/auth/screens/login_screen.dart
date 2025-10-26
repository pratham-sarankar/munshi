import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:munshi/features/auth/widgets/google_signin_button.dart';
import 'package:munshi/features/auth/widgets/gradient_background.dart';
import 'package:munshi/features/auth/widgets/munshi_logo.dart';
import '../widgets/feature_cards.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo animations
    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
          ),
        );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Title animations
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    // Subtitle animations
    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Button animations
    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
          ),
        );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() {
    // Handle Google sign-in logic here
    // TODO: Implement Google sign-in
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // Logo with glow effect
                  SlideTransition(
                    position: _logoSlideAnimation,
                    child: FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: const MunshiLogo(size: 96),
                    ),
                  ),

                  // Brand Name
                  SlideTransition(
                    position: _titleSlideAnimation,
                    child: FadeTransition(
                      opacity: _titleFadeAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xff556afc),
                            Color(0xff653de0),
                            Color(0xff653de0),
                          ],
                          stops: [0.0, 0.75, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          'Munshi',
                          style: GoogleFonts.manrope(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tagline
                  SlideTransition(
                    position: _subtitleSlideAnimation,
                    child: FadeTransition(
                      opacity: _subtitleFadeAnimation,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Your intelligent expense tracking companion',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            color: const Color(0xFF6B7280),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Login Section
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Sign In Button
                  SlideTransition(
                    position: _buttonSlideAnimation,
                    child: FadeTransition(
                      opacity: _buttonFadeAnimation,
                      child: GoogleSignInButton(onPressed: _handleGoogleSignIn),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Color(0xFFE5E7EB), thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Why Munshi?',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Color(0xFFE5E7EB), thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Features
                  const FeatureCards(),
                ],
              ),

              const Spacer(),
              // Footer
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Secured with end-to-end encryption',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
