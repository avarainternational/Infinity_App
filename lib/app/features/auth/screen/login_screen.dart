import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/constant/resources/app_images.dart';
import 'package:infinity_wellness/app/core/base/base_view.dart';
import 'package:infinity_wellness/app/features/auth/controller/auth_controller.dart';

class LoginScreen extends BaseView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // 1. Top Logo + App Name + Underline
                      _buildBrandHeader(),

                      const SizedBox(height: 36),

                      // 2. Center Slogan (Myanmar Text)
                      _buildCenterSlogan(),

                      const SizedBox(height: 36),

                      // 3. Footer: Google Login Button + Infinity Water signature
                      _buildFooterSection(context),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Logo from Assets
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0077B6).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              AppImages.infinityWellnessLogo,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // App Name
        const Text(
          'Infinity Wellness',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Clean Horizontal Underline
        Container(
          width: 120,
          height: 2.0,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterSlogan() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ချစ်ရသူတွေနဲ့',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            height: 1.4,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'ဝေ မျှရင်းဂရုစိုက်လိုက်ပါ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            height: 1.4,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Google OAuth Sign In Button
        Obx(
          () => SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.signInWithGoogle(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textDark,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGoogleLogo(),
                        const SizedBox(width: 12),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 26),

        // Footer Brand Signature
        const Column(
          children: [
            Text(
              'By Infinity Water',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'ရေသန့်ထက်ပိုသောရေသန့်',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint bluePaint = Paint()..color = AppColors.googleBlue;
    final Paint greenPaint = Paint()..color = AppColors.googleGreen;
    final Paint yellowPaint = Paint()..color = AppColors.googleYellow;
    final Paint redPaint = Paint()..color = AppColors.googleRed;

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Red segment (top)
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 * 0.75,
        3.14159 * 0.5,
        false,
      )
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Yellow segment (left)
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        3.14159 * 0.75,
        3.14159 * 0.5,
        false,
      )
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Green segment (bottom)
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        3.14159 * 0.25,
        3.14159 * 0.5,
        false,
      )
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Blue segment (right)
    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 * 0.25,
        3.14159 * 0.5,
        false,
      )
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Inner cutout
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.58, innerPaint);

    // Right crossbar
    final barPaint = Paint()..color = AppColors.googleBlue;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx - 1,
        center.dy - radius * 0.22,
        radius * 1.05,
        radius * 0.44,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
