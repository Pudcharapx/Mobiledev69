import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';
import '../models/utility_usage.dart';

class UtilityAnalyticsCard extends StatefulWidget {
  final UtilityAnalyticsData? data;

  const UtilityAnalyticsCard({super.key, this.data});

  @override
  State<UtilityAnalyticsCard> createState() => _UtilityAnalyticsCardState();
}

class _UtilityAnalyticsCardState extends State<UtilityAnalyticsCard> {
  bool _isElectricity = true; // true = Electricity, false = Water

  @override
  Widget build(BuildContext context) {
    final analytics = widget.data ?? UtilityAnalyticsData.mockDefault();
    final records = analytics.historicalRecords;

    final isElec = _isElectricity;
    final primaryColor = isElec ? const Color(0xFFFF9500) : const Color(0xFF007AFF);
    final gradientColors = isElec
        ? [const Color(0xFFFF9500), const Color(0xFFFFB300)]
        : [const Color(0xFF007AFF), const Color(0xFF5AC8FA)];

    final currentVal = isElec
        ? analytics.currentMonth.electricityUnits
        : analytics.currentMonth.waterUnits;
    final unitLabel = isElec ? 'kWh' : 'm³';
    final deltaPercent = isElec ? analytics.electricityDeltaPercent : analytics.waterDeltaPercent;
    final averageVal = isElec ? analytics.averageElectricityUnits : analytics.averageWaterUnits;
    final insightText = isElec ? analytics.electricityInsight : analytics.waterInsight;

    // Find max value for bar normalization
    final maxVal = records.fold<double>(
      0.1,
      (max, r) => math.max(max, isElec ? r.electricityUnits : r.waterUnits),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, size: 20, color: DormMateColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Usage Analytics',
                    style: DormMateTextStyles.sectionTitle,
                  ),
                ],
              ),
              // Segmented Toggle Pill
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: DormMateColors.isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DormMateColors.divider),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isElectricity = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isElec
                              ? (DormMateColors.isDark ? const Color(0xFF1E293B) : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isElec
                              ? const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 14,
                              color: isElec ? const Color(0xFFFF9500) : DormMateColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Power',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isElec ? FontWeight.w700 : FontWeight.w500,
                                color: isElec ? DormMateColors.textPrimary : DormMateColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isElectricity = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: !isElec
                              ? (DormMateColors.isDark ? const Color(0xFF1E293B) : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: !isElec
                              ? const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.water_drop_rounded,
                              size: 14,
                              color: !isElec ? const Color(0xFF007AFF) : DormMateColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Water',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: !isElec ? FontWeight.w700 : FontWeight.w500,
                                color: !isElec ? DormMateColors.textPrimary : DormMateColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Current Value & Comparison Metric
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentVal.toStringAsFixed(isElec ? 0 : 1),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: DormMateColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unitLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DormMateColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Delta badge
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: deltaPercent > 0
                      ? (DormMateColors.isDark ? const Color(0x33E11D48) : const Color(0xFFFFEBE8))
                      : (DormMateColors.isDark ? const Color(0x3310B981) : const Color(0xFFE8F8EE)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      deltaPercent > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 12,
                      color: deltaPercent > 0
                          ? (DormMateColors.isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48))
                          : (DormMateColors.isDark ? const Color(0xFF34D399) : const Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${deltaPercent.abs().toStringAsFixed(1)}% vs prev',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: deltaPercent > 0
                            ? (DormMateColors.isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48))
                            : (DormMateColors.isDark ? const Color(0xFF34D399) : const Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'Avg: ${averageVal.toStringAsFixed(1)} $unitLabel',
                  style: TextStyle(
                    fontSize: 11,
                    color: DormMateColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom Native Bar Chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: records.asMap().entries.map((entry) {
                final idx = entry.key;
                final record = entry.value;
                final isLast = idx == records.length - 1;
                final val = isElec ? record.electricityUnits : record.waterUnits;
                final barRatio = (val / (maxVal * 1.15)).clamp(0.12, 1.0);
                final barHeight = 85.0 * barRatio;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        Text(
                          val.toStringAsFixed(isElec ? 0 : 1),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
                            color: isLast ? primaryColor : DormMateColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bar Container
                        Container(
                          width: double.infinity,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: isLast
                                ? LinearGradient(
                                    colors: gradientColors,
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : null,
                            color: isLast
                                ? null
                                : (DormMateColors.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isLast
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Month label
                        Text(
                          record.monthLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isLast ? FontWeight.w800 : FontWeight.w500,
                            color: isLast ? DormMateColors.textPrimary : DormMateColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Energy Insight Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DormMateColors.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DormMateColors.divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: isElec ? const Color(0xFFFF9500) : const Color(0xFF007AFF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insightText,
                    style: TextStyle(
                      fontSize: 12,
                      color: DormMateColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
