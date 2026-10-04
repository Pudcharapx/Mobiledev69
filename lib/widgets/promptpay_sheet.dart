import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';

void showPromptPaySheet(
  BuildContext context, {
  required String billingMonth,
  required double totalAmount,
  String billTitle = 'Monthly Dormitory Fees',
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
                const SizedBox(height: 12),

                // PromptPay Header Logo Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003D6B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 18),
                      Text(
                        'PROMPTPAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'พร้อมเพย์',
                        style: TextStyle(
                          color: Color(0xFF80D8FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  context.tr('Dormitory Management (Building B)', 'สำนักงานหอพักนักศึกษา (อาคาร B)'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DormMateColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),

                // PromptPay Number & Copy Button
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      'PromptPay ID: 089-123-4567',
                      style: TextStyle(
                        fontSize: 12,
                        color: DormMateColors.textSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: '0891234567'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('PromptPay ID copied to clipboard', 'คัดลอกรหัสพร้อมเพย์แล้ว')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.copy_rounded, size: 15, color: DormMateColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Responsive QR Code Card (compact to prevent overflow)
                const PromptPayQRCodeWidget(size: 150),

                const SizedBox(height: 12),

                // Total Amount Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: DormMateColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DormMateColors.divider),
                  ),
                  child: Column(
                    children: [
                      Text(
                        billingMonth.isNotEmpty
                            ? '${context.tr('Billing', 'รอบบิล')}: $billingMonth'
                            : context.tr(billTitle, 'ค่าใช้จ่ายหอพักประจำเดือน'),
                        style: TextStyle(fontSize: 11, color: DormMateColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '฿${totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: DormMateColors.isDark ? const Color(0xFF38BDF8) : const Color(0xFF003D6B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('QR Code saved to photo album', 'บันทึกภาพ QR Code ลงในเครื่องแล้ว')),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 17),
                        label: Text(context.tr('Save QR', 'บันทึกภาพ')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DormMateColors.isDark ? const Color(0xFF0284C7) : const Color(0xFF003D6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('Payment slip uploaded! Dorm staff will verify.', 'ส่งสลิปชำระเงินแล้ว! เจ้าหน้าที่จะตรวจสอบข้อมูล')),
                              backgroundColor: DormMateColors.statusCompleted,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                        icon: const Icon(Icons.upload_file_rounded, size: 17),
                        label: Text(context.tr('Attach Slip', 'แนบสลิป')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class PromptPayQRCodeWidget extends StatelessWidget {
  final double size;

  const PromptPayQRCodeWidget({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1F000000), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size - 20, size - 20),
            painter: _PromptPayMatrixPainter(),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF003D6B),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_rounded, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptPayMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF003D6B)
      ..style = PaintingStyle.fill;

    final double moduleSize = size.width / 21;

    void drawFinderPattern(double startX, double startY) {
      // 7x7 outer square
      canvas.drawRect(
        Rect.fromLTWH(startX, startY, moduleSize * 7, moduleSize * 7),
        paint,
      );
      // 5x5 inner white
      canvas.drawRect(
        Rect.fromLTWH(startX + moduleSize, startY + moduleSize, moduleSize * 5, moduleSize * 5),
        Paint()..color = Colors.white,
      );
      // 3x3 center square
      canvas.drawRect(
        Rect.fromLTWH(startX + moduleSize * 2, startY + moduleSize * 2, moduleSize * 3, moduleSize * 3),
        paint,
      );
    }

    // Three QR Finder Eyes
    drawFinderPattern(0, 0); // Top-left
    drawFinderPattern(size.width - moduleSize * 7, 0); // Top-right
    drawFinderPattern(0, size.height - moduleSize * 7); // Bottom-left

    // Alignment and data modules pattern
    const matrix = [
      [0,0,0,0,0,0,0, 0, 1,0,1,1,0, 0, 0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0, 0, 0,1,0,0,1, 0, 0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0, 0, 1,1,1,0,1, 0, 0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0, 0, 0,1,0,1,0, 0, 0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0, 0, 1,0,1,1,0, 0, 0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0, 0, 0,1,0,0,1, 0, 0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0, 0, 1,1,1,0,1, 0, 0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0, 0, 0,0,1,1,0, 0, 0,0,0,0,0,0,0],
      [1,0,1,0,1,0,1, 1, 0,1,0,1,0, 1, 1,0,1,0,1,0,1],
      [0,1,0,1,0,1,0, 1, 1,0,0,0,1, 1, 0,1,0,1,0,1,0],
      [1,0,1,0,1,0,1, 0, 0,0,0,0,0, 0, 1,0,1,0,1,0,1],
      [1,1,0,1,0,1,1, 1, 0,0,0,0,0, 1, 1,1,0,1,0,1,1],
      [0,1,1,0,1,0,0, 0, 0,0,0,0,0, 0, 0,1,1,0,1,0,0],
      [0,0,0,0,0,0,0, 0, 1,1,0,1,1, 0, 1,0,1,0,1,1,0],
      [0,0,0,0,0,0,0, 0, 0,1,1,0,0, 1, 0,1,1,0,0,1,1],
      [0,0,0,0,0,0,0, 0, 1,0,0,1,1, 0, 1,1,0,1,0,0,1],
      [0,0,0,0,0,0,0, 0, 0,1,0,1,0, 1, 0,0,1,1,0,1,0],
      [0,0,0,0,0,0,0, 0, 1,1,1,0,1, 0, 1,0,0,0,1,1,1],
      [0,0,0,0,0,0,0, 0, 0,0,1,1,0, 1, 0,1,0,1,0,0,0],
      [0,0,0,0,0,0,0, 0, 1,0,0,1,1, 0, 1,1,1,0,1,0,1],
      [0,0,0,0,0,0,0, 0, 0,1,1,0,0, 1, 0,0,0,1,0,1,0],
    ];

    for (int r = 0; r < matrix.length; r++) {
      for (int c = 0; c < matrix[r].length; c++) {
        // Skip finder zone
        if ((r < 7 && c < 7) || (r < 7 && c > 13) || (r > 13 && c < 7)) {
          continue;
        }
        if (matrix[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(c * moduleSize, r * moduleSize, moduleSize * 0.95, moduleSize * 0.95),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
