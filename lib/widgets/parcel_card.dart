import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';
import '../models/parcel.dart';
import 'status_badge.dart';
import 'parcel_pickup_sheet.dart';
import 'neumorphic.dart';

class ParcelCard extends StatelessWidget {
  final Parcel parcel;
  final Future<bool> Function(String id) onClaim;

  const ParcelCard({
    super.key,
    required this.parcel,
    required this.onClaim,
  });

  Color _getCarrierColor(String carrier) {
    final c = carrier.toLowerCase();
    if (c.contains('flash')) return const Color(0xFFF59E0B); // Flash Yellow/Orange
    if (c.contains('spx') || c.contains('shopee')) return const Color(0xFFEA580C); // Shopee Orange
    if (c.contains('kerry')) return const Color(0xFFFF6F00); // Kerry Amber
    if (c.contains('post') || c.contains('ems')) return const Color(0xFFDC2626); // Thai Post Red
    if (c.contains('j&t') || c.contains('jt')) return const Color(0xFFE11D48); // J&T Red
    return DormMateColors.primary;
  }

  IconData _getCarrierIcon(String carrier) {
    return Icons.local_shipping_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final carrierColor = _getCarrierColor(parcel.carrier);

    return NeuContainer(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 18,
      shadowIntensity: 0.85,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showParcelPickupSheet(context, parcel: parcel, onClaim: onClaim),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Carrier badge, location, and status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          carrierColor.withValues(alpha: 0.22),
                          carrierColor.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: carrierColor.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Icon(_getCarrierIcon(parcel.carrier), color: carrierColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parcel.carrier,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DormMateColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.place_outlined, size: 12, color: DormMateColors.textTertiary),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                parcel.shelfLocation,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: DormMateColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: parcel.isReady ? 'Active' : 'Completed'),
                ],
              ),
              const SizedBox(height: 12),

              // Middle Divider
              Container(
                height: 1,
                color: isDark ? const Color(0xFF28334E) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 10),

              // Bottom Row: Tracking Number + Copy and Pickup QR Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.tag_rounded, size: 14, color: DormMateColors.textTertiary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            parcel.trackingNumber,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                              color: DormMateColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: parcel.trackingNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('Tracking number copied to clipboard', 'คัดลอกหมายเลขพัสดุแล้ว')),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Icon(Icons.copy_rounded, size: 14, color: DormMateColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: parcel.isReady
                          ? DormMateColors.primary
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      foregroundColor: parcel.isReady
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => showParcelPickupSheet(context, parcel: parcel, onClaim: onClaim),
                    icon: Icon(
                      Icons.qr_code_2_rounded,
                      size: 14,
                      color: parcel.isReady
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                    ),
                    label: Text(
                      parcel.isReady ? context.tr('Pickup QR', 'คิวอาร์รับของ') : context.tr('Details', 'รายละเอียด'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
