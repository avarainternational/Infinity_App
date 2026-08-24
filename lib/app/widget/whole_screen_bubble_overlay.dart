import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Single bubble particle with organic underwater physics
class BubbleParticle {
  BubbleParticle({
    required this.xRatio,
    required this.yProgressOffset,
    required this.radius,
    required this.speed,
    required this.wobbleSpeed,
    required this.wobbleAmp,
    required this.wobblePhase,
    required this.baseAlpha,
    required this.color,
    required this.glowColor,
    required this.hasSecondaryHighlight,
  });

  final double xRatio; // 0.0 to 1.0
  final double yProgressOffset; // staggered initial offset
  final double radius;
  final double speed; // pixels per second
  final double wobbleSpeed;
  final double wobbleAmp;
  final double wobblePhase;
  final double baseAlpha;
  final Color color;
  final Color glowColor;
  final bool hasSecondaryHighlight;

  // Pop burst physics (active when hold completes)
  double popProgress = 0.0;
  double popVelocityX = 0.0;
  double popVelocityY = 0.0;
}

/// Miniature water splash particle radiating on 100% completion
class SplashParticle {
  SplashParticle({
    required this.origin,
    required this.angle,
    required this.speed,
    required this.radius,
    required this.color,
  });

  final Offset origin;
  final double angle;
  final double speed;
  final double radius;
  final Color color;

  double progress = 0.0;
}

/// Whole screen bubble animation overlay widget
class WholeScreenBubbleOverlayWidget extends StatefulWidget {
  const WholeScreenBubbleOverlayWidget({
    super.key,
    required this.fillAnimation,
    required this.buttonOrigin,
    required this.navBarTop,
    required this.isHoldingNotifier,
    required this.isCompletedNotifier,
    this.onDismissed,
  });

  final Animation<double> fillAnimation;
  final Offset buttonOrigin;
  final double navBarTop;
  final ValueNotifier<bool> isHoldingNotifier;
  final ValueNotifier<bool> isCompletedNotifier;
  final VoidCallback? onDismissed;

  @override
  State<WholeScreenBubbleOverlayWidget> createState() =>
      _WholeScreenBubbleOverlayWidgetState();
}

class _WholeScreenBubbleOverlayWidgetState
    extends State<WholeScreenBubbleOverlayWidget>
    with TickerProviderStateMixin {
  late final AnimationController _tickerController;
  late final AnimationController _fadeController;
  late final AnimationController _burstController;

  final List<BubbleParticle> _bubbles = [];
  final List<SplashParticle> _splashParticles = [];
  final math.Random _random = math.Random();

  double _elapsedTime = 0.0;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    // 60FPS continuous particle loop
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_onTick);
    _tickerController.repeat();

    // Fade-in / Fade-out controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeController.forward();

    // Burst celebration controller
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _initBubbles();

    widget.isHoldingNotifier.addListener(_onHoldStateChanged);
    widget.isCompletedNotifier.addListener(_onCompletedStateChanged);
  }

  void _initBubbles() {
    _bubbles.clear();
    const totalBubbles = 44;

    final palette = [
      const Color(0xFF00D2FF), // Vibrant Cyan
      const Color(0xFF38B6FF), // Sky Blue
      const Color(0xFF80E5FF), // Ice Cyan
      const Color(0xFFFFFFFF), // Pure White
      const Color(0xFF0099FF), // Vivid Deep Cyan
      const Color(0xFFB3F0FF), // Luminous Glow Cyan
    ];

    for (int i = 0; i < totalBubbles; i++) {
      // Natural distribution across width
      final rawX = _random.nextDouble();
      final biasedX = 0.5 + (rawX - 0.5) * 0.94;

      final radius = _random.nextDouble() < 0.18
          ? 20.0 + _random.nextDouble() * 22.0 // Hero bubble
          : (_random.nextDouble() < 0.52
              ? 11.0 + _random.nextDouble() * 10.0 // Medium bubble
              : 4.5 + _random.nextDouble() * 6.0); // Micro bubble

      // Gentle, serene bubble speeds (reduced as requested)
      final speed = 45.0 + _random.nextDouble() * 85.0;
      final wobbleSpeed = 0.8 + _random.nextDouble() * 1.4;
      final wobbleAmp = 5.0 + _random.nextDouble() * 12.0;
      final wobblePhase = _random.nextDouble() * 2 * math.pi;
      final baseAlpha = 0.40 + _random.nextDouble() * 0.45;
      final color = palette[_random.nextInt(palette.length)];
      final glowColor = color.withValues(alpha: 0.55);

      _bubbles.add(
        BubbleParticle(
          xRatio: biasedX.clamp(0.02, 0.98),
          yProgressOffset: _random.nextDouble() * 1.2, // Staggered starting height
          radius: radius,
          speed: speed,
          wobbleSpeed: wobbleSpeed,
          wobbleAmp: wobbleAmp,
          wobblePhase: wobblePhase,
          baseAlpha: baseAlpha,
          color: color,
          glowColor: glowColor,
          hasSecondaryHighlight: radius > 13.0,
        ),
      );
    }
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {
      _elapsedTime += 0.016; // approx 60fps delta
    });
  }

  void _onHoldStateChanged() {
    if (!widget.isHoldingNotifier.value &&
        !widget.isCompletedNotifier.value &&
        !_isExiting) {
      // Released before 100% -> smooth graceful fade out
      _dismissWithFade();
    }
  }

  void _onCompletedStateChanged() {
    if (widget.isCompletedNotifier.value) {
      _triggerCelebrationBurst();
    }
  }

  void _triggerCelebrationBurst() {
    // Generate splash particle burst from button origin
    _splashParticles.clear();
    const totalSplash = 24;
    for (int i = 0; i < totalSplash; i++) {
      final angle = -math.pi + (_random.nextDouble() * math.pi); // Upward semi-circle
      final speed = 140.0 + _random.nextDouble() * 240.0;
      final radius = 2.5 + _random.nextDouble() * 4.0;
      final color = _random.nextBool()
          ? const Color(0xFF00D2FF)
          : const Color(0xFFFFFFFF);

      _splashParticles.add(
        SplashParticle(
          origin: widget.buttonOrigin,
          angle: angle,
          speed: speed,
          radius: radius,
          color: color,
        ),
      );
    }

    // Set gentle pop trajectory for existing bubbles
    for (final b in _bubbles) {
      final popAngle = -math.pi * 0.5 + (_random.nextDouble() - 0.5) * 1.6;
      b.popVelocityX = math.cos(popAngle) * (60.0 + _random.nextDouble() * 120.0);
      b.popVelocityY = math.sin(popAngle) * (80.0 + _random.nextDouble() * 160.0);
    }

    _burstController.forward(from: 0.0).then((_) {
      _dismissWithFade();
    });
  }

  void _dismissWithFade() {
    if (_isExiting) return;
    _isExiting = true;
    _fadeController.reverse().then((_) {
      if (mounted) {
        widget.onDismissed?.call();
      }
    });
  }

  @override
  void dispose() {
    widget.isHoldingNotifier.removeListener(_onHoldStateChanged);
    widget.isCompletedNotifier.removeListener(_onCompletedStateChanged);
    _tickerController.dispose();
    _fadeController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeController,
          _burstController,
          widget.fillAnimation,
        ]),
        builder: (context, child) {
          final globalFade = _fadeController.value;
          final burstProgress = _burstController.value;
          final fillProgress = widget.fillAnimation.value;

          return Opacity(
            opacity: globalFade,
            child: SizedBox.expand(
              child: CustomPaint(
                painter: _WholeScreenBubblePainter(
                  bubbles: _bubbles,
                  splashParticles: _splashParticles,
                  elapsedTime: _elapsedTime,
                  fillProgress: fillProgress,
                  burstProgress: burstProgress,
                  isCompleted: widget.isCompletedNotifier.value,
                  buttonOrigin: widget.buttonOrigin,
                  navBarTop: widget.navBarTop,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that renders the realistic bubbly underwater atmosphere
class _WholeScreenBubblePainter extends CustomPainter {
  _WholeScreenBubblePainter({
    required this.bubbles,
    required this.splashParticles,
    required this.elapsedTime,
    required this.fillProgress,
    required this.burstProgress,
    required this.isCompleted,
    required this.buttonOrigin,
    required this.navBarTop,
  });

  final List<BubbleParticle> bubbles;
  final List<SplashParticle> splashParticles;
  final double elapsedTime;
  final double fillProgress;
  final double burstProgress;
  final bool isCompleted;
  final Offset buttonOrigin;
  final double navBarTop;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseLineY = navBarTop.clamp(0.0, h);

    // -------------------------------------------------------------------------
    // 1. Ambient Liquid Atmosphere (Rises from top of nav bar upwards)
    // -------------------------------------------------------------------------
    final atmosphereAlpha =
        ((0.06 + (fillProgress * 0.18)) * (1.0 - burstProgress * 0.4))
            .clamp(0.0, 0.35);

    final bgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF0077E6).withValues(alpha: atmosphereAlpha * 1.1),
        const Color(0xFF00D2FF).withValues(alpha: atmosphereAlpha * 0.60),
        const Color(0xFF38B6FF).withValues(alpha: atmosphereAlpha * 0.22),
        Colors.transparent,
      ],
      stops: const [0.0, 0.40, 0.75, 1.0],
    );

    final bgPaint = Paint()
      ..shader = bgGradient.createShader(Rect.fromLTWH(0, 0, w, baseLineY));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, baseLineY), bgPaint);

    // Ambient radial glow emanating upwards from behind the nav bar
    final glowRadius = (130.0 + (fillProgress * 180.0)).clamp(100.0, 380.0);
    final buttonGlowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (buttonOrigin.dx / w) * 2 - 1,
          (baseLineY / h) * 2 - 1,
        ),
        radius: glowRadius / w,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.22 + (fillProgress * 0.18)),
          const Color(0xFF0089D8).withValues(alpha: 0.08 + (fillProgress * 0.10)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, baseLineY));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, baseLineY), buttonGlowPaint);

    // -------------------------------------------------------------------------
    // 2. Liquid Wave Starting From Top Of Nav Bar (Behind Nav Bar)
    // -------------------------------------------------------------------------
    _drawBottomLiquidWaves(canvas, size, w, h, baseLineY);

    // -------------------------------------------------------------------------
    // 3. Render Rising Iridescent Glass Bubbles (Gentle speeds)
    // -------------------------------------------------------------------------
    for (final bubble in bubbles) {
      _drawBubble(canvas, size, bubble, w, h, baseLineY);
    }

    // -------------------------------------------------------------------------
    // 4. Render Celebration Splash Particles & Shockwave on 100% Completion
    // -------------------------------------------------------------------------
    if (isCompleted && burstProgress > 0.0) {
      _drawCompletionCelebration(canvas, size, w, h);
    }
  }

  void _drawBottomLiquidWaves(
    Canvas canvas,
    Size size,
    double w,
    double h,
    double baseLineY,
  ) {
    // Dynamic wave height rising upward from the top edge of the nav bar
    final waveRiseHeight = 16.0 + (fillProgress * 70.0);
    final waveY = baseLineY - waveRiseHeight;

    final wavePath = Path();
    wavePath.moveTo(0, baseLineY);
    wavePath.lineTo(0, waveY);

    const waveCount = 1.6;
    final waveFrequency = (waveCount * 2 * math.pi) / w;
    final wavePhase = elapsedTime * 2.2; // Calm, gentle wave oscillation

    for (double x = 0; x <= w; x += 3) {
      final y = waveY + math.sin((x * waveFrequency) + wavePhase) * 5.0;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(w, baseLineY);
    wavePath.close();

    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00D2FF).withValues(alpha: 0.28 + (fillProgress * 0.28)),
          const Color(0xFF0066D6).withValues(alpha: 0.42 + (fillProgress * 0.28)),
        ],
      ).createShader(Rect.fromLTWH(0, waveY - 5, w, waveRiseHeight + 5));

    canvas.drawPath(wavePath, wavePaint);

    // Luminous crest highlight line along the wave top
    final crestPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final crestPath = Path();
    crestPath.moveTo(0, waveY);
    for (double x = 0; x <= w; x += 3) {
      final y = waveY + math.sin((x * waveFrequency) + wavePhase) * 5.0;
      crestPath.lineTo(x, y);
    }
    canvas.drawPath(crestPath, crestPaint);
  }

  void _drawBubble(
    Canvas canvas,
    Size size,
    BubbleParticle b,
    double w,
    double h,
    double baseLineY,
  ) {
    // Calculate vertical position starting from the top of the nav bar upwards
    final speedMultiplier = 1.0 + (fillProgress * 0.35);
    final totalDistance = baseLineY + 80.0;
    final currentDistance =
        (b.yProgressOffset * baseLineY + (elapsedTime * b.speed * speedMultiplier)) %
            totalDistance;
    final rawY = (baseLineY + 20.0) - currentDistance;

    // Horizontal wobble
    final wobbleX = math.sin((elapsedTime * b.wobbleSpeed) + b.wobblePhase) *
        b.wobbleAmp;
    final rawX = (b.xRatio * w) + wobbleX;

    // Center coordinates
    double cx = rawX;
    double cy = rawY;
    double r = b.radius;

    // If completion burst is active, apply burst velocity & expansion/fade
    double bubbleAlpha = b.baseAlpha;
    if (isCompleted && burstProgress > 0.0) {
      cx += b.popVelocityX * burstProgress;
      cy += b.popVelocityY * burstProgress;
      r *= (1.0 + burstProgress * 0.75); // Gentle expand before pop
      bubbleAlpha *= (1.0 - burstProgress).clamp(0.0, 1.0);
    }

    if (cy < -50 || cy > baseLineY + 30 || cx < -40 || cx > w + 40 || bubbleAlpha <= 0.01) {
      return;
    }

    // Breathing pulse
    final pulseScale = 1.0 + 0.035 * math.sin(elapsedTime * 2.8 + b.wobblePhase);
    r *= pulseScale;

    // 1. Outer Soft Glow Rim
    final glowPaint = Paint()
      ..color = b.glowColor.withValues(alpha: bubbleAlpha * 0.30)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.35);
    canvas.drawCircle(Offset(cx, cy), r * 1.08, glowPaint);

    // 2. Translucent Glassmorphic Body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.95,
        colors: [
          Colors.white.withValues(alpha: bubbleAlpha * 0.45),
          b.color.withValues(alpha: bubbleAlpha * 0.18),
          const Color(0xFF0070E0).withValues(alpha: bubbleAlpha * 0.32),
          b.color.withValues(alpha: bubbleAlpha * 0.70),
        ],
        stops: const [0.0, 0.45, 0.80, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    // 3. Crisp Glass Border / Rim Highlight
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r > 18 ? 1.5 : 1.0
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: bubbleAlpha * 0.95),
          b.color.withValues(alpha: bubbleAlpha * 0.35),
          Colors.white.withValues(alpha: bubbleAlpha * 0.75),
          const Color(0xFF0089D8).withValues(alpha: bubbleAlpha * 0.28),
          Colors.white.withValues(alpha: bubbleAlpha * 0.95),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawCircle(Offset(cx, cy), r, rimPaint);

    // 4. Primary Specular Gloss Crescent (Top-Left 3D Glint)
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: bubbleAlpha * 0.88)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (r * 0.13).clamp(1.2, 3.0);

    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78);
    canvas.drawArc(arcRect, -math.pi * 0.85, math.pi * 0.48, false, arcPaint);

    // 5. Bright Specular Reflection Dot
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: bubbleAlpha * 0.95)
      ..style = PaintingStyle.fill;

    final dotOffset = Offset(cx - (r * 0.42), cy - (r * 0.42));
    canvas.drawCircle(dotOffset, (r * 0.13).clamp(1.0, 3.2), dotPaint);

    // 6. Secondary Soft Bottom-Right Luminous Internal Reflection
    if (b.hasSecondaryHighlight) {
      final subGlintPaint = Paint()
        ..color = const Color(0xFFB8F5FF).withValues(alpha: bubbleAlpha * 0.50)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.3;

      final subArcRect =
          Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72);
      canvas.drawArc(subArcRect, math.pi * 0.15, math.pi * 0.35, false, subGlintPaint);
    }
  }

  void _drawCompletionCelebration(Canvas canvas, Size size, double w, double h) {
    // 1. Expanding Liquid Ripple Shockwave Ring from button origin
    final maxRippleRadius = math.max(w, h) * 0.95;
    final rippleRadius = burstProgress * maxRippleRadius;
    final rippleAlpha = (1.0 - burstProgress).clamp(0.0, 1.0);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8 * (1.0 - burstProgress)
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: rippleAlpha * 0.85),
          const Color(0xFF00D2FF).withValues(alpha: rippleAlpha * 0.65),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: buttonOrigin, radius: rippleRadius));

    canvas.drawCircle(buttonOrigin, rippleRadius, ringPaint);

    // 2. Sparkling Splash Droplets
    for (final splash in splashParticles) {
      final distance = splash.speed * burstProgress;
      final splashX = buttonOrigin.dx + math.cos(splash.angle) * distance;
      // Gravity drop effect
      final splashY = buttonOrigin.dy +
          math.sin(splash.angle) * distance +
          (220.0 * burstProgress * burstProgress);

      final splashAlpha = (1.0 - burstProgress).clamp(0.0, 1.0);

      final splashPaint = Paint()
        ..color = splash.color.withValues(alpha: splashAlpha * 0.9)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(splashX, splashY),
        splash.radius * (1.0 - (burstProgress * 0.3)),
        splashPaint,
      );

      // Micro glow for splash
      final sparkGlow = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: splashAlpha * 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(Offset(splashX, splashY), splash.radius * 1.6, sparkGlow);
    }
  }

  @override
  bool shouldRepaint(covariant _WholeScreenBubblePainter oldDelegate) {
    return true;
  }
}

