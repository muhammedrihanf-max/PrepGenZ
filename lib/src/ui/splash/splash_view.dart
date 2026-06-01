import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mathgame/src/core/app_constant.dart';
import 'package:mathgame/src/core/audio_manager.dart';
import 'package:provider/provider.dart';
import 'package:mathgame/src/ui/dashboard/dashboard_provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _glowPulse;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    // Play BGM automatically on opening the game
    AudioManager.instance.playGameplayBgm();

    // Main entrance animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Shimmer loop controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Particle float controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // Progress bar controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // Logo scale: 0 → overshoot → 1
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.55),
    ));

    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.6, curve: Curves.easeIn),
      ),
    );

    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.8, curve: Curves.easeIn),
      ),
    );

    _glowPulse = Tween(begin: 0.0, end: 1.0).animate(_shimmerController);

    _progressValue = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressController.forward();
    });

    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (mounted) {
        final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
        if (dashboardProvider.username.trim().isNotEmpty) {
          Navigator.pushReplacementNamed(context, KeyUtil.dashboard);
        } else {
          Navigator.pushReplacementNamed(context, KeyUtil.enterName);
        }
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1a0a0a),
                    Color(0xFF2d1810),
                    Color(0xFF3a1a0e),
                    Color(0xFF1e0d06),
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),

            // Animated floating particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                    screenSize: MediaQuery.of(context).size,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Radial glow behind logo
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, _) {
                final pulse = 0.3 + 0.15 * sin(_glowPulse.value * 2 * pi);
                return Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xffFF6B6B).withOpacity(pulse),
                          const Color(0xffEE5A24).withOpacity(pulse * 0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo icon area
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: _buildLogoWidget(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title: "MATH"
                      Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: Opacity(
                          opacity: _titleOpacity.value,
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, _) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: const [
                                      Color(0xFFFFFFFF),
                                      Color(0xFFFF6B6B),
                                      Color(0xFFFFFFFF),
                                    ],
                                    stops: [
                                      (_shimmerController.value - 0.3)
                                          .clamp(0.0, 1.0),
                                      _shimmerController.value,
                                      (_shimmerController.value + 0.3)
                                          .clamp(0.0, 1.0),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  "MATH",
                                  style: TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: "Poppins",
                                    color: Colors.white,
                                    letterSpacing: 14,
                                    height: 1.1,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Title: "GenZ"
                      Transform.translate(
                        offset: Offset(0, _titleSlide.value * 1.2),
                        child: Opacity(
                          opacity: _titleOpacity.value,
                          child: const Text(
                            "GenZ",
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Poppins",
                              color: Color(0xffFF6B6B),
                              letterSpacing: 14,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      Opacity(
                        opacity: _subtitleOpacity.value,
                        child: Text(
                          "Train Your Brain",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Progress bar
                      Opacity(
                        opacity: _subtitleOpacity.value,
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            return _buildProgressBar(_progressValue.value);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom credit
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, _) {
                  return Opacity(
                    opacity: _subtitleOpacity.value,
                    child: Text(
                      "© Muhammed Rihan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.35),
                        letterSpacing: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoWidget() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xffFF6B6B),
            Color(0xffEE5A24),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffFF6B6B).withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xffEE5A24).withOpacity(0.3),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Grid pattern inside logo
            _buildGridOverlay(),
            // Center "M" letter
            const Text(
              "M",
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                fontFamily: "Poppins",
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: 100,
        height: 100,
        child: CustomPaint(
          painter: _GridPainter(),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double value) {
    return SizedBox(
      width: 180,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            // Track
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Fill
            FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xffF9CA24),
                      Color(0xffFF6B6B),
                      Color(0xffEE5A24),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffFF6B6B).withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter for the subtle grid overlay on the logo
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 0.5;

    const count = 4;
    final cellW = size.width / count;
    final cellH = size.height / count;

    for (int i = 1; i < count; i++) {
      canvas.drawLine(
        Offset(cellW * i, 0),
        Offset(cellW * i, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, cellH * i),
        Offset(size.width, cellH * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data class for a floating particle
class _Particle {
  final String symbol;
  final double x; // normalized 0-1
  final double y; // normalized 0-1
  final double size;
  final double speed;
  final double opacity;
  final double phase;

  _Particle({
    required this.symbol,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

// Painter for floating math symbol particles
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Size screenSize;

  static final List<_Particle> _particles = _generateParticles();

  _ParticlePainter({
    required this.progress,
    required this.screenSize,
  });

  static List<_Particle> _generateParticles() {
    final random = Random(42);
    const symbols = [
      '+', '−', '×', '÷', '=', '%', '√', 'π',
      '∑', '∞', 'Δ', '∫', '≈', '≠', '±', '∂',
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ];

    return List.generate(35, (i) {
      return _Particle(
        symbol: symbols[random.nextInt(symbols.length)],
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 12.0 + random.nextDouble() * 16.0,
        speed: 0.3 + random.nextDouble() * 0.7,
        opacity: 0.06 + random.nextDouble() * 0.14,
        phase: random.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final animY =
          (p.y + progress * p.speed * 0.3) % 1.0;
      final driftX =
          p.x + sin(progress * 2 * pi * p.speed + p.phase) * 0.03;

      final dx = driftX * size.width;
      final dy = animY * size.height;

      final textPainter = TextPainter(
        text: TextSpan(
          text: p.symbol,
          style: TextStyle(
            fontSize: p.size,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(p.opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) {
    return old.progress != progress;
  }
}
