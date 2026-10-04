import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../core/localization/language_service.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';
import '../../widgets/promptpay_sheet.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/language_toggle_button.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final int expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseViewModel>().selectExpense(widget.expenseId);
    });
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      try {
        context.go('/expenses');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exp = vm.selectedExpense;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgDark : NeuColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _handleBack,
        ),
        title: Text(
          context.tr('Expense Details', 'รายละเอียดค่าใช้จ่าย'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A2035),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          LanguageToggleButton(isDark: isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedOrbBackground(
        isDark: isDark,
        child: vm.isLoading
            ? LoadingView(message: context.tr('Loading details...', 'กำลังโหลดรายละเอียด...'))
            : vm.errorMessage != null
                ? ErrorView(
                    message: vm.errorMessage!,
                    onRetry: () => vm.selectExpense(widget.expenseId),
                  )
                : exp == null
                    ? EmptyStateView(
                        icon: Icons.receipt_outlined,
                        title: context.tr('Not Found', 'ไม่พบข้อมูล'),
                        subtitle: context.tr('The selected expense could not be found.', 'ไม่พบรายการค่าใช้จ่ายที่เลือก'),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header card
                            NeuContainer(
                              isDark: isDark,
                              padding: const EdgeInsets.all(22),
                              borderRadius: 22,
                              shadowIntensity: 0.85,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        exp.displayMonth,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: DormMateColors.textPrimary,
                                        ),
                                      ),
                                      StatusBadge(status: exp.paymentStatus),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    '฿${exp.total.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: DormMateColors.textPrimary,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (exp.dueDate != null)
                                    Text(
                                      context.tr('Payment Due: ${exp.dueDate}', 'ครบกำหนดชำระ: ${exp.dueDate}'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: DormMateColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),
                            Text(
                              context.tr('Itemized Charges', 'รายการค่าใช้จ่าย'),
                              style: DormMateTextStyles.sectionTitle,
                            ),
                            const SizedBox(height: 10),

                            NeuContainer(
                              isDark: isDark,
                              padding: const EdgeInsets.all(20),
                              borderRadius: 20,
                              child: Column(
                                children: [
                                  ExpenseBreakdownRow(
                                    icon: Icons.bolt_rounded,
                                    iconColor: const Color(0xFFE6AC00),
                                    iconBgColor: const Color(0x1FFFCC00),
                                    label: context.tr('Electricity Charge', 'ค่าไฟฟ้า'),
                                    amount: exp.electricity,
                                  ),
                                  Divider(height: 1, color: isDark ? const Color(0xFF28334E) : DormMateColors.divider),
                                  ExpenseBreakdownRow(
                                    icon: Icons.water_drop_outlined,
                                    iconColor: const Color(0xFF007AFF),
                                    iconBgColor: const Color(0x1A007AFF),
                                    label: context.tr('Water Charge', 'ค่าน้ำประปา'),
                                    amount: exp.water,
                                  ),
                                  Divider(height: 1, color: isDark ? const Color(0xFF28334E) : DormMateColors.divider),
                                  ExpenseBreakdownRow(
                                    icon: Icons.wifi_rounded,
                                    iconColor: DormMateColors.primary,
                                    iconBgColor: const Color(0x1A5856D6),
                                    label: context.tr('Internet Access Fee', 'ค่าอินเทอร์เน็ต'),
                                    amount: exp.internet,
                                  ),
                                  Divider(height: 1, color: isDark ? const Color(0xFF28334E) : DormMateColors.divider),
                                  ExpenseBreakdownRow(
                                    icon: Icons.grid_view_rounded,
                                    iconColor: DormMateColors.textTertiary,
                                    iconBgColor: isDark ? const Color(0x1FFFFFFF) : const Color(0x0F000000),
                                    label: context.tr('Other Maintenance / Fees', 'ค่าบำรุงรักษา / อื่นๆ'),
                                    amount: exp.other,
                                  ),
                                  const SizedBox(height: 10),
                                  Divider(height: 1, color: isDark ? const Color(0xFF28334E) : DormMateColors.divider),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.tr('Grand Total', 'ยอดรวมสุทธิ'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: DormMateColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '฿${exp.total.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF667EEA),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // PromptPay Payment Action Button
                            NeuButton(
                              isDark: isDark,
                              gradientColors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                              borderRadius: 16,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              onTap: () => showPromptPaySheet(
                                context,
                                billingMonth: exp.displayMonth,
                                totalAmount: exp.total,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.qr_code_2_rounded, size: 22, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      exp.paymentStatus.toLowerCase() == 'paid'
                                          ? context.tr('View PromptPay QR / Receipt', 'ดูคิวอาร์พร้อมเพย์ / ใบเสร็จ')
                                          : context.tr('Pay via PromptPay QR (สแกนจ่ายพร้อมเพย์)', 'สแกนจ่ายผ่าน PromptPay QR'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 96),
                          ],
                        ),
                      ),
      ),
    );
  }
}
