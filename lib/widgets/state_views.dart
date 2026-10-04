import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';

class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(DormMateColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: TextStyle(
                fontSize: 13,
                color: DormMateColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: DormMateColors.statusErrorBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: DormMateColors.statusErrorText,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: DormMateColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text(context.tr('Try Again', 'ลองใหม่อีกครั้ง')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0x0A000000),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: DormMateColors.textTertiary, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DormMateColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: DormMateColors.textSecondary,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: DormMateColors.primary,
                  side: BorderSide(color: DormMateColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                  ),
                ),
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
