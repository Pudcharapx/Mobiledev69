import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';
import '../models/parcel.dart';
import 'promptpay_sheet.dart';

void showParcelPickupSheet(
  BuildContext context, {
  required Parcel parcel,
  required Future<bool> Function(String id) onClaim,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: DormMateColors.surfaceWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DormMateColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),

                // Carrier Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: DormMateColors.isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        parcel.carrier.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  context.tr('Parcel Pickup Pass', 'บัตรรับพัสดุ'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DormMateColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('Show this QR code or PIN to the front desk officer', 'แสดง QR Code หรือรหัสนี้ต่อเจ้าหน้าที่เพื่อรับพัสดุ'),
                  style: TextStyle(
                    fontSize: 12,
                    color: DormMateColors.textSecondary.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Pickup QR Code
                const PromptPayQRCodeWidget(size: 160),

                const SizedBox(height: 14),

                // Pickup PIN Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: DormMateColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: DormMateColors.divider, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.tr('PICKUP CODE', 'รหัสรับพัสดุ'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: DormMateColors.textTertiary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        parcel.pickupCode,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: DormMateColors.primary,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DormMateColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: DormMateColors.divider),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(context.tr('Tracking No.', 'เลขพัสดุ'), parcel.trackingNumber, canCopy: true, context: context),
                      Divider(height: 14, color: DormMateColors.divider),
                      _buildInfoRow(context.tr('Location', 'จุดรับพัสดุ'), parcel.shelfLocation),
                      Divider(height: 14, color: DormMateColors.divider),
                      _buildInfoRow(context.tr('Recipient', 'ผู้รับ'), '${parcel.recipientName} (${parcel.roomNumber})'),
                      Divider(height: 14, color: DormMateColors.divider),
                      _buildInfoRow(context.tr('Arrived At', 'เวลาที่มาถึง'), parcel.displayArrivedDate),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Action Buttons
                if (parcel.isReady) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final success = await onClaim(parcel.id);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('Parcel marked as claimed!', 'รับพัสดุเรียบร้อยแล้ว')),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: Text(
                        context.tr('Confirm Claimed', 'ยืนยันรับพัสดุแล้ว'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        context.tr('This parcel has been claimed', 'รับพัสดุรายการนี้เรียบร้อยแล้ว'),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildInfoRow(String label, String value, {bool canCopy = false, BuildContext? context}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: DormMateColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DormMateColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
            if (canCopy && context != null) ...[
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('$label copied to clipboard', 'คัดลอก $label แล้ว')),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.copy_rounded, size: 14, color: DormMateColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
