import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';
import '../models/expense.dart';
import 'status_badge.dart';
import 'app_animations.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final Expense expense;

  const ExpenseSummaryCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4338CA),
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DormMateDimens.radiusXl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.38),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Ambient glowing orb top-right
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  expense.displayMonthLocale(context.isThai).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CountUpAmount(
                targetAmount: expense.total,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                expense.dueDate != null
                    ? (context.isThai ? 'ครบกำหนดชำระ ${expense.dueDate}' : 'Due ${expense.dueDate}')
                    : context.tr('Monthly expenses', 'ค่าใช้จ่ายประจำเดือน'),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: StatusBadge(status: expense.paymentStatus),
          ),
        ],
      ),
    );
  }
}

class ExpenseBreakdownRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final double amount;

  const ExpenseBreakdownRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DormMateColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            '฿${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DormMateColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
