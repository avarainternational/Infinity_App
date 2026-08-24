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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Icon & Header
                  _buildBrandHeader(),
                  const SizedBox(height: 36),

                  // Main Card with Features & Sign In Button
                  _buildLoginCard(context),
                  const SizedBox(height: 28),

                  // Footer Note
                  _buildFooterNote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            AppImages.logo,
            width: 84,
            height: 84,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.violet],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.surface,
                  size: 44,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Infinity Wellness',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'by Infinity Water',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your youth digital health & mutual synergy companion',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textBody,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Get Started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sign in to sync your hydration streaks and 1-on-1 synergy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 22),

          // Feature highlights
          _buildFeatureRow(
            icon: Icons.auto_awesome_rounded,
            color: AppColors.primary,
            title: 'Evidence-Based Literacy',
            subtitle: 'Curated medical news and myth-busting',
          ),
          const SizedBox(height: 12),
          _buildFeatureRow(
            icon: Icons.water_rounded,
            color: AppColors.primary,
            title: 'Smart Hydration Goal',
            subtitle: 'Dynamic calculations for your body & activity',
          ),
          const SizedBox(height: 12),
          _buildFeatureRow(
            icon: Icons.people_alt_rounded,
            color: AppColors.violet,
            title: '1-on-1 Synergy',
            subtitle: 'Mutual live nudges with your best friend',
          ),
          const SizedBox(height: 26),

          // Google OAuth Sign In Button
          Obx(
            () => SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.signInWithGoogle(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 1,
                  shadowColor: Colors.black26,
                  side: const BorderSide(color: AppColors.borderLight, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGoogleLogo(),
                          const SizedBox(width: 12),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSubtitle,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSlate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleIconPainter(),
      ),
    );
  }

  Widget _buildFooterNote() {
    return const Column(
      children: [
        Text(
          'Protected by Supabase PostgreSQL & Row Level Security',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSlate,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'By continuing, you agree to Infinity Wellness terms & privacy standards.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.5,
            color: AppColors.textLight,
          ),
        ),
      ],
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
    final innerPaint = Paint()..color = AppColors.surface;
    canvas.drawCircle(center, radius * 0.58, innerPaint);

    // Right crossbar
    final barPaint = Paint()..color = AppColors.googleBlue;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - 1, center.dy - radius * 0.22, radius * 1.05, radius * 0.44),
      const Radius.circular(2),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
