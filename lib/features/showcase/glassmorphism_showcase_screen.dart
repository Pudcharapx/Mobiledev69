import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/ambient_mesh_background.dart';
import '../../core/widgets/app_top_nav_bar.dart';
import '../../core/widgets/glass_container.dart';

/// Interactive showcase screen displaying luxury Glassmorphism UI components.
class GlassmorphismShowcaseScreen extends StatefulWidget {
  const GlassmorphismShowcaseScreen({super.key});

  @override
  State<GlassmorphismShowcaseScreen> createState() =>
      _GlassmorphismShowcaseScreenState();
}

class _GlassmorphismShowcaseScreenState
    extends State<GlassmorphismShowcaseScreen> {
  double _blurValue = 16.0;
  double _sliderValue = 75.0;
  bool _switchValue = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppTopNavBar(
        title: 'Glassmorphism UI',
        showBackButton: true,
      ),
      body: AmbientMeshBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Glassmorphism Header Card
                    GlassCard(
                      blur: _blurValue,
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Glassmorphism Luxury UI',
                                  style: AppTypography.headlineLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Frosted glass with specular edge reflections and ambient glow.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Fitness Stats Frosted Glass Card
                    GlassContainer(
                      blur: _blurValue,
                      borderRadius: 28,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weekly Balance Score',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Chest, Back & Legs volume',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: const Text(
                                  '95% Optimal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Metrics Row
                          Row(
                            children: [
                              // Circular ring preview
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      value: _sliderValue / 100,
                                      strokeWidth: 9,
                                      backgroundColor: Colors.white
                                          .withValues(alpha: 0.1),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF06B6D4),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${_sliderValue.round()}%',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMetricRow(
                                      label: 'Intensity',
                                      value: 'Optimal 8.4/10',
                                      color: const Color(0xFF06B6D4),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMetricRow(
                                      label: 'Recovery',
                                      value: '92% Rested',
                                      color: const Color(0xFF10B981),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMetricRow(
                                      label: 'Streak',
                                      value: '5 Days Active',
                                      color: const Color(0xFFF59E0B),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Interactive Glass Controls Card
                    GlassCard(
                      blur: _blurValue,
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live Blur Adjuster',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Blur Sigma: ${_blurValue.toStringAsFixed(1)} px',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          Slider(
                            value: _blurValue,
                            min: 4.0,
                            max: 32.0,
                            activeColor: const Color(0xFF6366F1),
                            onChanged: (val) {
                              setState(() => _blurValue = val);
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Balance Score: ${_sliderValue.round()}%',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          Slider(
                            value: _sliderValue,
                            min: 0.0,
                            max: 100.0,
                            activeColor: const Color(0xFF06B6D4),
                            onChanged: (val) {
                              setState(() => _sliderValue = val);
                            },
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ambient Frosted Glow',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Enhance specular highlight reflection',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _switchValue,
                                activeThumbColor: const Color(0xFF6366F1),
                                onChanged: (v) =>
                                    setState(() => _switchValue = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Glass Buttons Showcase
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Glass Button Pressed! ✨'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.star_rounded,
                              color: Colors.amberAccent,
                              size: 18,
                            ),
                            label: 'Interactive Glass',
                            accentColor: const Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                            ),
                            label: 'Back to Home',
                            accentColor: AppColors.accent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
