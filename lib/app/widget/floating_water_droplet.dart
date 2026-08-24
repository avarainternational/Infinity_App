import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/features/home/controller/home_controller.dart';
import 'package:infinity_wellness/app/features/hydration/controller/hydration_detail_controller.dart';
import 'package:infinity_wellness/app/widget/whole_screen_bubble_overlay.dart';

/// Interactive Floating Water Droplet that requires a 2-second hold
/// to log water with a realistic water wave filling animation,
/// full-screen effervescent bubble rise atmosphere,
/// or a quick tap to perform navigation/actions.
class FloatingWaterDroplet extends StatefulWidget {
  const FloatingWaterDroplet({
    super.key,
    this.amountMl = 250,
    this.onWaterLogged,
    this.onTap,
    this.isSelected = false,
    this.isHighlighted = true,
    this.showTooltip = false,
    this.width = 56.0,
    this.height = 66.0,
  });

  final int amountMl;
  final ValueChanged<int>? onWaterLogged;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isHighlighted;
  final bool showTooltip;
  final double width;
  final double height;

  @override
  State<FloatingWaterDroplet> createState() => _FloatingWaterDropletState();
}

class _FloatingWaterDropletState extends State<FloatingWaterDroplet>
    with TickerProviderStateMixin {
  late final AnimationController _fillController;
  late final AnimationController _waveController;
  late final AnimationController _splashController;

  final ValueNotifier<bool> _isHoldingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isCompletedNotifier = ValueNotifier<bool>(false);
  OverlayEntry? _bubbleOverlayEntry;

  bool _isHolding = false;
  bool _isCompleted = false;
  DateTime? _pointerDownTime;
  int _lastHapticMilestone = 0;

  @override
  void initState() {
    super.initState();

    // 2-second hold controller for filling the water
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Wave animation active during hold
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Splash burst animation on 100% completion
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fillController.addListener(() {
      if (_isHolding) {
        // Haptic feedback tick every 20% progress
        final currentMilestone = (_fillController.value * 5).floor();
        if (currentMilestone > _lastHapticMilestone) {
          _lastHapticMilestone = currentMilestone;
          HapticFeedback.selectionClick();
        }
      }
    });

    _fillController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isCompleted) {
        _handleHoldCompleted();
      }
    });
  }

  @override
  void dispose() {
    _removeBubbleOverlay();
    _isHoldingNotifier.dispose();
    _isCompletedNotifier.dispose();
    _fillController.dispose();
    _waveController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  void _showBubbleOverlay() {
    _removeBubbleOverlay();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final mediaQuery = MediaQuery.of(context);
    // Determine droplet button center origin and top edge of navigation bar
    Offset origin = Offset(
      mediaQuery.size.width / 2,
      mediaQuery.size.height - 50,
    );
    double navBarTop = mediaQuery.size.height - 85.0;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      origin = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
      // Nav bar top border is located above the droplet top edge
      navBarTop = origin.dy - (widget.height / 2) - 8.0;
    }

    _isHoldingNotifier.value = true;
    _isCompletedNotifier.value = false;

    _bubbleOverlayEntry = OverlayEntry(
      builder: (context) => WholeScreenBubbleOverlayWidget(
        fillAnimation: _fillController,
        buttonOrigin: origin,
        navBarTop: navBarTop,
        isHoldingNotifier: _isHoldingNotifier,
        isCompletedNotifier: _isCompletedNotifier,
        onDismissed: () {
          _removeBubbleOverlay();
        },
      ),
    );

    overlay.insert(_bubbleOverlayEntry!);
  }

  void _removeBubbleOverlay() {
    _bubbleOverlayEntry?.remove();
    _bubbleOverlayEntry = null;
  }

  void _onHoldStart() {
    if (_isCompleted) return;

    _pointerDownTime = DateTime.now();
    _lastHapticMilestone = 0;

    setState(() {
      _isHolding = true;
    });

    _showBubbleOverlay();

    HapticFeedback.lightImpact();
    _waveController.repeat();
    _fillController.forward(from: 0.0);
  }

  void _onHoldEnd() {
    // If not completed and released quickly -> trigger tap
    if (!_isCompleted && _pointerDownTime != null) {
      final elapsed =
          DateTime.now().difference(_pointerDownTime!).inMilliseconds;
      if (elapsed < 350) {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      }
    }

    _cancelHold();
  }

  void _cancelHold() {
    _waveController.stop();
    _isHoldingNotifier.value = false;

    if (_isHolding) {
      setState(() {
        _isHolding = false;
      });
      // Drain water smoothly back down if released early
      _fillController.reverse();
    }
  }

  void _handleHoldCompleted() {
    setState(() {
      _isCompleted = true;
      _isHolding = false;
    });

    _isHoldingNotifier.value = false;
    _isCompletedNotifier.value = true;

    _waveController.stop();
    HapticFeedback.heavyImpact();
    _splashController.forward(from: 0.0);

    // Trigger water logging
    final amount = widget.amountMl;
    if (widget.onWaterLogged != null) {
      widget.onWaterLogged!(amount);
    } else {
      _logWaterToControllers(amount);
    }

    // Reset after celebratory animation (smooth 650ms)
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _isCompleted = false;
          _isHolding = false;
        });
        _isHoldingNotifier.value = false;
        _isCompletedNotifier.value = false;
        _fillController.reset();
        _splashController.reset();
      }
    });
  }

  void _logWaterToControllers(int amount) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().logWater(amount);
    } else if (Get.isRegistered<HydrationDetailController>()) {
      Get.find<HydrationDetailController>().logIntake(amount);
    } else {
      if (Get.context != null) {
        Get.snackbar(
          'Water Logged! 💧',
          '+$amount ml added to your daily hydration.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropletWidth = widget.width;
    final dropletHeight = widget.height;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _fillController,
        _waveController,
        _splashController,
      ]),
      builder: (context, child) {
        final fillProgress = _fillController.value;
        final waveValue = _waveController.value;
        final splashValue = _splashController.value;

        // Scale springs up slightly when holding
        final scale = _isHolding
            ? 1.08 + (fillProgress * 0.06)
            : (_isCompleted ? 1.15 : 1.0);

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Splash ripple ring on completion
            if (splashValue > 0.0)
              Positioned(
                child: Container(
                  width: dropletWidth + (splashValue * 60),
                  height: dropletHeight + (splashValue * 60),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryVibrant.withValues(
                        alpha: (1.0 - splashValue).clamp(0.0, 1.0) * 0.8,
                      ),
                      width: 3.5 * (1.0 - splashValue),
                    ),
                  ),
                ),
              ),

            // Hint Tooltip (Shown only if explicitly enabled and idle)
            if (widget.showTooltip &&
                !_isHolding &&
                !_isCompleted &&
                fillProgress == 0.0)
              Positioned(
                top: -28,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 11, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Hold 2s to log',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Main Droplet Interactive Container
            Listener(
              key: const Key('water_droplet_button'),
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => _onHoldStart(),
              onPointerUp: (_) => _onHoldEnd(),
              onPointerCancel: (_) => _onHoldEnd(),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: dropletWidth,
                  height: dropletHeight,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: [
                      // Vibrant Ambient Water Glow Shadow
                      BoxShadow(
                        color: AppColors.primaryVibrant.withValues(
                          alpha: _isHolding
                              ? 0.55 + (fillProgress * 0.25)
                              : (widget.isSelected ? 0.42 : 0.28),
                        ),
                        blurRadius: _isHolding ? 20 : 14,
                        spreadRadius: _isHolding ? 2.5 : 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _WaterDropletPainter(
                      fillProgress: fillProgress,
                      wavePhase: waveValue * 2 * math.pi,
                      isHolding: _isHolding,
                      isCompleted: _isCompleted,
                      amountMl: widget.amountMl,
                      isHighlighted: widget.isHighlighted,
                      isSelected: widget.isSelected,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom Painter that renders the droplet shape, liquid wave fill, specular highlights, and label
class _WaterDropletPainter extends CustomPainter {
  _WaterDropletPainter({
    required this.fillProgress,
    required this.wavePhase,
    required this.isHolding,
    required this.isCompleted,
    required this.amountMl,
    required this.isHighlighted,
    required this.isSelected,
  });

  final double fillProgress;
  final double wavePhase;
  final bool isHolding;
  final bool isCompleted;
  final int amountMl;
  final bool isHighlighted;
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Create Teardrop Droplet Path
    final dropletPath = Path();
    dropletPath.moveTo(w * 0.5, 0); // Top sharp tip
    // Right curve
    dropletPath.cubicTo(w * 0.65, h * 0.18, w, h * 0.50, w, h * 0.72);
    // Bottom bulb curve
    dropletPath.cubicTo(w, h * 0.94, w * 0.78, h, w * 0.5, h);
    // Left bulb curve
    dropletPath.cubicTo(w * 0.22, h, 0, h * 0.94, 0, h * 0.72);
    // Left curve back to top
    dropletPath.cubicTo(0, h * 0.50, w * 0.35, h * 0.18, w * 0.5, 0);
    dropletPath.close();

    // 2. Draw Chamber Background (Highlighted Vibrant Blue)
    final backgroundPaint = Paint();
    if (isHighlighted) {
      backgroundPaint.shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF38B6FF), // Cyan-blue top
          Color(0xFF008CF0), // Vibrant middle
          Color(0xFF0060DB), // Deep rich blue bottom
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    } else {
      backgroundPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.85),
          const Color(0xFFE0F4FF).withValues(alpha: 0.90),
          const Color(0xFFBCE5FB).withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    }

    canvas.drawPath(dropletPath, backgroundPaint);

    // 3. Clip within Droplet Path for Liquid Wave Fill
    canvas.save();
    canvas.clipPath(dropletPath);

    // Calculate water baseline Y (0% -> h, 100% -> 0)
    final waterLevelY = h - (h * fillProgress.clamp(0.0, 1.0));

    if (fillProgress > 0.0 || isCompleted) {
      // Build Wave Path
      final wavePath = Path();
      const waveAmplitude = 4.0;
      const waveFrequency = 0.09;

      wavePath.moveTo(0, waterLevelY);

      for (double x = 0; x <= w; x += 2) {
        final y = waterLevelY +
            math.sin((x * waveFrequency) + wavePhase) * waveAmplitude;
        wavePath.lineTo(x, y);
      }

      wavePath.lineTo(w, h);
      wavePath.lineTo(0, h);
      wavePath.close();

      // Liquid Fill Gradient (Crisp illuminated water layer)
      final waterPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isHighlighted
              ? const [
                  Color(0xFFB8F5FF), // Luminous ice cyan crest
                  Color(0xFF00D2FF), // Electric cyan
                  Color(0xFF0070E0), // Deep blue base
                ]
              : const [
                  Color(0xFF38B6FF),
                  Color(0xFF0099FF),
                  Color(0xFF0066D6),
                ],
        ).createShader(Rect.fromLTWH(0, 0, w, h));

      canvas.drawPath(wavePath, waterPaint);

      // Foam / Surface crest highlight
      final foamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;

      final foamPath = Path();
      foamPath.moveTo(0, waterLevelY);
      for (double x = 0; x <= w; x += 2) {
        final y = waterLevelY +
            math.sin((x * waveFrequency) + wavePhase) * waveAmplitude;
        foamPath.lineTo(x, y);
      }
      canvas.drawPath(foamPath, foamPaint);

      // Rising bubbles inside water
      if (isHolding && fillProgress > 0.15) {
        final bubblePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..style = PaintingStyle.fill;

        final b1Y = waterLevelY + (h - waterLevelY) * 0.65;
        final b2Y = waterLevelY + (h - waterLevelY) * 0.35;
        canvas.drawCircle(Offset(w * 0.35, b1Y), 2.0, bubblePaint);
        canvas.drawCircle(Offset(w * 0.68, b2Y), 1.6, bubblePaint);
      }
    }

    canvas.restore();

    // 4. Outer Glowing Droplet Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHolding ? 2.6 : 2.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isHighlighted
            ? [
                Colors.white.withValues(alpha: 0.95),
                const Color(0xFF80D8FF).withValues(alpha: 0.8),
                const Color(0xFF0044AA).withValues(alpha: 0.6),
              ]
            : [
                Colors.white.withValues(alpha: 0.9),
                AppColors.primary.withValues(alpha: 0.6),
                AppColors.primaryDark.withValues(alpha: 0.8),
              ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(dropletPath, borderPaint);

    // 5. Specular Gloss Reflection (Top left curved highlight)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isHighlighted ? 0.75 : 0.65)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6;

    final highlightPath = Path();
    highlightPath.moveTo(w * 0.38, h * 0.22);
    highlightPath.quadraticBezierTo(w * 0.18, h * 0.45, w * 0.22, h * 0.65);
    canvas.drawPath(highlightPath, highlightPaint);

    // 6. Center Content (Water/Home Icon / Percentage / Success Checkmark)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (isCompleted) {
      // Completed Checkmark Icon
      const icon = Icons.check_rounded;
      final iconPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: 24,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      )..layout();

      iconPainter.paint(
        canvas,
        Offset((w - iconPainter.width) / 2, (h - iconPainter.height) / 2 + 5),
      );
    } else if (isHolding && fillProgress > 0.0) {
      // Percentage Counter (e.g. "45%")
      final percent = (fillProgress * 100).toInt();
      textPainter.text = TextSpan(
        text: '$percent%',
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black45,
              blurRadius: 4,
            ),
          ],
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2 + 7),
      );
    } else {
      // Idle: Drinking Cup Icon with Plus Sign Badge
      const cupIcon = Icons.local_drink_rounded;
      final cupPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(cupIcon.codePoint),
          style: TextStyle(
            fontSize: 27,
            fontFamily: cupIcon.fontFamily,
            package: cupIcon.fontPackage,
            color: isHighlighted ? Colors.white : AppColors.primary,
            shadows: isHighlighted
                ? const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
        ),
      )..layout();

      // Paint cup icon centered in the droplet
      final cupX = (w - cupPainter.width) / 2 - 2;
      final cupY = (h - cupPainter.height) / 2 + 5;
      cupPainter.paint(canvas, Offset(cupX, cupY));

      // Plus badge icon at top-right of the cup
      const plusIcon = Icons.add_rounded;
      final plusPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(plusIcon.codePoint),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            fontFamily: plusIcon.fontFamily,
            package: plusIcon.fontPackage,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black38,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      )..layout();

      final plusX = cupX + cupPainter.width - 6;
      final plusY = cupY + 1;
      plusPainter.paint(canvas, Offset(plusX, plusY));
    }
  }

  @override
  bool shouldRepaint(covariant _WaterDropletPainter oldDelegate) {
    return oldDelegate.fillProgress != fillProgress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.isHolding != isHolding ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.isHighlighted != isHighlighted ||
        oldDelegate.isSelected != isSelected;
  }
}
