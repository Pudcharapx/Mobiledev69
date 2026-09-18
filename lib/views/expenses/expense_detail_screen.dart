import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';
import '../../widgets/promptpay_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseViewModel>();
    final exp = vm.selectedExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
      ),
      body: vm.isLoading
          ? const LoadingView(message: 'Loading details...')
          : vm.errorMessage != null
              ? ErrorView(
                  message: vm.errorMessage!,
                  onRetry: () => vm.selectExpense(widget.expenseId),
                )
              : exp == null
                  ? const EmptyStateView(
                      icon: Icons.receipt_outlined,
                      title: 'Not Found',
                      subtitle: 'The selected expense could not be found.',
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header card
                          GlassCard(
                            padding: const EdgeInsets.all(22),
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
                                    'Payment Due: ${exp.dueDate}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: DormMateColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          Text(
                            'Itemized Charges',
                            style: DormMateTextStyles.sectionTitle,
                          ),
                          const SizedBox(height: 10),

                          GlassCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                ExpenseBreakdownRow(
                                  icon: Icons.bolt_rounded,
                                  iconColor: const Color(0xFFE6AC00),
                                  iconBgColor: const Color(0x1FFFCC00),
                                  label: 'Electricity Charge',
                                  amount: exp.electricity,
                                ),
                                Divider(height: 1, color: DormMateColors.divider),
                                ExpenseBreakdownRow(
                                  icon: Icons.water_drop_outlined,
                                  iconColor: const Color(0xFF007AFF),
                                  iconBgColor: const Color(0x1A007AFF),
                                  label: 'Water Charge',
                                  amount: exp.water,
                                ),
                                Divider(height: 1, color: DormMateColors.divider),
                                ExpenseBreakdownRow(
                                  icon: Icons.wifi_rounded,
                                  iconColor: DormMateColors.primary,
                                  iconBgColor: const Color(0x1A5856D6),
                                  label: 'Internet Access Fee',
                                  amount: exp.internet,
                                ),
                                Divider(height: 1, color: DormMateColors.divider),
                                ExpenseBreakdownRow(
                                  icon: Icons.grid_view_rounded,
                                  iconColor: DormMateColors.textTertiary,
                                  iconBgColor: DormMateColors.isDark ? const Color(0x1FFFFFFF) : const Color(0x0F000000),
                                  label: 'Other Maintenance / Fees',
                                  amount: exp.other,
                                ),
                                const SizedBox(height: 10),
                                Divider(height: 1, color: DormMateColors.divider),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Grand Total',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: DormMateColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '฿${exp.total.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: DormMateColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // PromptPay Payment Action Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DormMateColors.isDark ? const Color(0xFF0284C7) : const Color(0xFF003D6B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () => showPromptPaySheet(
                                context,
                                billingMonth: exp.displayMonth,
                                totalAmount: exp.total,
                              ),
                              icon: const Icon(Icons.qr_code_2_rounded, size: 22),
                              label: Text(
                                exp.paymentStatus.toLowerCase() == 'paid'
                                    ? 'View PromptPay QR / Receipt'
                                    : 'Pay via PromptPay QR (สแกนจ่ายพร้อมเพย์)',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),

                          const SizedBox(height: 96),
                        ],
                      ),
                    ),
    );
  }
}
