import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/muscle_volume_calculator.dart';

/// Body SVG widget displaying Front and Back views with dynamic muscle zone heatmap colors
/// per SRS.md section 8.1.
class BodySvgWidget extends StatelessWidget {
  final Map<String, MuscleVolumeData> volumeData;
  final ValueChanged<String>? onZoneTapped;

  const BodySvgWidget({
    super.key,
    required this.volumeData,
    this.onZoneTapped,
  });

  String _hex(String muscleGroup) {
    final color = volumeData[muscleGroup]?.color ?? AppColors.heatmapDefault;
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }

  String _getFrontSvg() {
    final shoulders = _hex('shoulders');
    final chest = _hex('chest');
    final biceps = _hex('biceps');
    final core = _hex('core');
    final legs = _hex('legs');
    const neutral = '#94A3B8';

    return '''
<svg viewBox="0 0 200 320" xmlns="http://www.w3.org/2000/svg">
  <!-- Head & Neck -->
  <ellipse cx="100" cy="30" rx="18" ry="22" fill="$neutral" opacity="0.35"/>
  <rect x="94" y="50" width="12" height="12" rx="3" fill="$neutral" opacity="0.35"/>

  <!-- Left Shoulder -->
  <path d="M72,62 C60,63 52,70 50,82 C56,84 66,80 72,75 Z" fill="$shoulders"/>
  <!-- Right Shoulder -->
  <path d="M128,62 C140,63 148,70 150,82 C144,84 134,80 128,75 Z" fill="$shoulders"/>

  <!-- Chest (Pectorals) -->
  <path d="M75,68 C85,68 98,72 98,92 C88,94 76,92 72,82 Z" fill="$chest"/>
  <path d="M125,68 C115,68 102,72 102,92 C112,94 124,92 128,82 Z" fill="$chest"/>

  <!-- Left Bicep & Arm -->
  <path d="M48,84 C42,94 40,110 44,124 C48,124 54,116 56,104 C56,94 54,86 48,84 Z" fill="$biceps"/>
  <path d="M42,126 C38,138 34,152 30,165 C34,168 40,162 44,150 C46,140 44,130 42,126 Z" fill="$neutral" opacity="0.25"/>

  <!-- Right Bicep & Arm -->
  <path d="M152,84 C158,94 160,110 156,124 C152,124 146,116 144,104 C144,94 146,86 152,84 Z" fill="$biceps"/>
  <path d="M158,126 C162,138 166,152 170,165 C166,168 160,162 156,150 C154,140 156,130 158,126 Z" fill="$neutral" opacity="0.25"/>

  <!-- Core (Abs / Obliques) -->
  <path d="M76,96 C85,96 115,96 124,96 C122,120 120,140 116,152 C106,155 94,155 84,152 C80,140 78,120 76,96 Z" fill="$core"/>

  <!-- Pelvis -->
  <path d="M84,154 C94,156 106,156 116,154 C118,164 114,172 100,174 C86,172 82,164 84,154 Z" fill="$neutral" opacity="0.3"/>

  <!-- Left Leg (Quads & Calves) -->
  <path d="M76,172 C88,172 96,174 96,204 C94,226 90,244 86,252 C78,252 74,230 72,204 C70,186 72,176 76,172 Z" fill="$legs"/>
  <path d="M74,256 C74,272 74,290 70,305 C76,308 82,308 84,295 C86,282 86,268 84,256 Z" fill="$legs"/>

  <!-- Right Leg (Quads & Calves) -->
  <path d="M124,172 C112,172 104,174 104,204 C106,226 110,244 114,252 C122,252 126,230 128,204 C130,186 128,176 124,172 Z" fill="$legs"/>
  <path d="M126,256 C126,272 126,290 130,305 C124,308 118,308 116,295 C114,282 114,268 116,256 Z" fill="$legs"/>
</svg>
''';
  }

  String _getBackSvg() {
    final shoulders = _hex('shoulders');
    final back = _hex('back');
    final triceps = _hex('triceps');
    final glutes = _hex('glutes');
    final hamstrings = _hex('hamstrings');
    const neutral = '#94A3B8';

    return '''
<svg viewBox="0 0 200 320" xmlns="http://www.w3.org/2000/svg">
  <!-- Head & Neck -->
  <ellipse cx="100" cy="30" rx="18" ry="22" fill="$neutral" opacity="0.35"/>
  <rect x="94" y="50" width="12" height="12" rx="3" fill="$neutral" opacity="0.35"/>

  <!-- Left Rear Delt (Shoulder) -->
  <path d="M72,62 C60,63 52,70 50,82 C56,84 66,80 72,75 Z" fill="$shoulders"/>
  <!-- Right Rear Delt (Shoulder) -->
  <path d="M128,62 C140,63 148,70 150,82 C144,84 134,80 128,75 Z" fill="$shoulders"/>

  <!-- Back (Traps & Lats) -->
  <path d="M74,68 C88,62 112,62 126,68 C128,94 124,124 118,142 C108,146 92,146 82,142 C76,124 72,94 74,68 Z" fill="$back"/>

  <!-- Left Tricep & Arm -->
  <path d="M48,84 C42,94 40,110 44,124 C48,124 54,116 56,104 C56,94 54,86 48,84 Z" fill="$triceps"/>
  <path d="M42,126 C38,138 34,152 30,165 C34,168 40,162 44,150 C46,140 44,130 42,126 Z" fill="$neutral" opacity="0.25"/>

  <!-- Right Tricep & Arm -->
  <path d="M152,84 C158,94 160,110 156,124 C152,124 146,116 144,104 C144,94 146,86 152,84 Z" fill="$triceps"/>
  <path d="M158,126 C162,138 166,152 170,165 C166,168 160,162 156,150 C154,140 156,130 158,126 Z" fill="$neutral" opacity="0.25"/>

  <!-- Glutes -->
  <path d="M80,146 C90,146 98,154 98,174 C86,176 76,170 76,156 Z" fill="$glutes"/>
  <path d="M120,146 C110,146 102,154 102,174 C114,176 124,170 124,156 Z" fill="$glutes"/>

  <!-- Left Hamstrings -->
  <path d="M76,176 C88,176 96,178 96,208 C94,228 90,246 86,252 C78,252 74,230 72,208 C72,190 74,180 76,176 Z" fill="$hamstrings"/>
  <path d="M74,256 C74,272 74,290 70,305 C76,308 82,308 84,295 C86,282 86,268 84,256 Z" fill="$hamstrings"/>

  <!-- Right Hamstrings -->
  <path d="M124,176 C112,176 104,178 104,208 C106,228 110,246 114,252 C122,252 126,230 128,208 C128,190 126,180 124,176 Z" fill="$hamstrings"/>
  <path d="M126,256 C126,272 126,290 130,305 C124,308 118,308 116,295 C114,282 114,268 116,256 Z" fill="$hamstrings"/>
</svg>
''';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Front & Back SVGs side by side
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Front Body View
            Expanded(
              child: Column(
                children: [
                  Text(
                    'FRONT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 260,
                    child: SvgPicture.string(
                      _getFrontSvg(),
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // Back Body View
            Expanded(
              child: Column(
                children: [
                  Text(
                    'BACK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 260,
                    child: SvgPicture.string(
                      _getBackSvg(),
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Color Legend Bar (SRS 8.1: red -> yellow -> green)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(
                color: AppColors.heatmapUnderTrained,
                label: '<50% Under',
              ),
              _LegendItem(
                color: AppColors.heatmapModerate,
                label: '50-79% Moderate',
              ),
              _LegendItem(
                color: AppColors.heatmapOptimal,
                label: '80%+ Target Met',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Muscle Group Badges (tap a zone to view popup with contributing logs)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: MuscleVolumeCalculator.muscleGroups.map((group) {
            final data = volumeData[group];
            final percent = data?.percentageInt ?? 0;
            final color = data?.color ?? AppColors.heatmapDefault;

            return ActionChip(
              avatar: CircleAvatar(
                backgroundColor: color,
                radius: 6,
              ),
              label: Text(
                '${group.toUpperCase()} ($percent%)',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              onPressed: () => onZoneTapped?.call(group),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
