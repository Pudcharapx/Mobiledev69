import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color dot;

    switch (status.toLowerCase()) {
      case 'in progress':
      case 'inprogress':
      case 'active':
        bg = DormMateColors.statusInProgressBg;
        text = DormMateColors.statusInProgressText;
        dot = DormMateColors.statusInProgress;
        break;
      case 'completed':
      case 'done':
      case 'paid':
        bg = DormMateColors.statusCompletedBg;
        text = DormMateColors.statusCompletedText;
        dot = DormMateColors.statusCompleted;
        break;
      case 'unpaid':
      case 'cancelled':
      case 'error':
        bg = DormMateColors.statusErrorBg;
        text = DormMateColors.statusErrorText;
        dot = DormMateColors.statusError;
        break;
      case 'pending':
      default:
        bg = DormMateColors.statusPendingBg;
        text = DormMateColors.statusPendingText;
        dot = DormMateColors.statusPending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dot.withValues(alpha: 0.32),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: dot.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.5,
            height: 6.5,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dot.withValues(alpha: 0.7),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5.5),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: text,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
