import 'package:flutter/material.dart';

class FeatureCard extends StatefulWidget {

  const FeatureCard({
    required this.icon, required this.title, required this.subtitle, required this.gradientColors, required this.backgroundGradientColors, required this.borderColor, super.key,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final List<Color> backgroundGradientColors;
  final Color borderColor;

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: widget.backgroundGradientColors,
                ),
                border: Border.all(color: widget.borderColor),
              ),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.gradientColors.first.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FeatureCards extends StatefulWidget {
  const FeatureCards({super.key});

  @override
  State<FeatureCards> createState() => _FeatureCardsState();
}

class _FeatureCardsState extends State<FeatureCards>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    // Create animation controllers for staggered animation
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    // Create slide animations with staggered delays
    _slideAnimations = _animationControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    }).toList();

    // Start animations with staggered delays
    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    for (var i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Auto-sync transactions card
        SlideTransition(
          position: _slideAnimations[0],
          child: const FeatureCard(
            icon: Icons.mail_outline,
            title: 'Auto-sync transactions',
            subtitle: 'From your email notifications',
            gradientColors: [Color(0xFF6366F1), Color(0xFF6366F1)],
            backgroundGradientColors: [Color(0xFFF0F9FF), Color(0xFFEDE9FE)],
            borderColor: Color(0xFFE0E7FF),
          ),
        ),
        const SizedBox(height: 16),

        // Privacy first card
        SlideTransition(
          position: _slideAnimations[1],
          child: const FeatureCard(
            icon: Icons.lock_outline,
            title: 'Privacy first',
            subtitle: 'Data stays on your device',
            gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
            backgroundGradientColors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
            borderColor: Color(0xFFA7F3D0),
          ),
        ),
        const SizedBox(height: 16),

        // Smart insights card
        SlideTransition(
          position: _slideAnimations[2],
          child: const FeatureCard(
            icon: Icons.auto_awesome_outlined,
            title: 'Smart insights',
            subtitle: 'AI-powered categorization',
            gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            backgroundGradientColors: [Color(0xFFFAF5FF), Color(0xFFFDF2F8)],
            borderColor: Color(0xFFE9D5FF),
          ),
        ),
      ],
    );
  }
}
