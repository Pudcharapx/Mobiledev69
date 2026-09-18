import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';
import '../../widgets/promptpay_sheet.dart';
import '../../models/expense.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseViewModel>().loadExpenses();
    });
  }

  void _showUnpaidSelectionSheet(BuildContext context, List<Expense> unpaidExpenses) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: DormMateColors.surfaceWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DormMateColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Unpaid Bills',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: DormMateColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DormMateColors.statusErrorBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${unpaidExpenses.length} Overdue',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DormMateColors.statusErrorText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a bill below to view PromptPay QR and proceed with payment.',
                    style: TextStyle(
                      fontSize: 12,
                      color: DormMateColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List of unpaid bills
                  ...unpaidExpenses.map((exp) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: DormMateColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFF9F9FB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: DormMateColors.divider),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(ctx);
                          showPromptPaySheet(
                            context,
                            billingMonth: exp.displayMonth,
                            totalAmount: exp.total,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: DormMateColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: DormMateColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exp.displayMonth,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: DormMateColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      exp.dueDate != null ? 'Due: ${exp.dueDate}' : 'Monthly Bill',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: DormMateColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '฿${exp.total.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: DormMateColors.isDark ? const Color(0xFF38BDF8) : const Color(0xFF003D6B),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Pay',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: DormMateColors.primary,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 16,
                                        color: DormMateColors.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  if (unpaidExpenses.length > 1) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DormMateColors.isDark ? const Color(0xFF0284C7) : const Color(0xFF003D6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DormMateDimens.radiusMd),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          final totalAll = unpaidExpenses.fold<double>(0, (s, e) => s + e.total);
                          showPromptPaySheet(
                            context,
                            billingMonth: 'All Unpaid Bills (${unpaidExpenses.length} Months)',
                            totalAmount: totalAll,
                          );
                        },
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: Text(
                          'Pay All Unpaid (฿${unpaidExpenses.fold<double>(0, (s, e) => s + e.total).toStringAsFixed(0)})',
                          style: const TextStyle(fontWeight: FontWeight.w700),
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseViewModel>();
    final unpaidExpenses = vm.expenses.where((e) => !e.isPaid).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses', style: DormMateTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'ขั้นตอนการชำระเงิน',
            onPressed: () => showFeatureGuideSheet(context, FeatureGuide.paymentGuide),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Usage Analytics',
            onPressed: () => context.push('/expenses/analytics'),
          ),
        ],
      ),
      body: vm.isLoading && vm.expenses.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                children: [
                  ShimmerSkeletonCard(height: 140, borderRadius: 24),
                  ShimmerSkeletonCard(height: 240, borderRadius: 20),
                  ShimmerSkeletonCard(height: 60, borderRadius: 16),
                ],
              ),
            )
          : vm.errorMessage != null && vm.expenses.isEmpty
              ? ErrorView(
                  message: vm.errorMessage!,
                  onRetry: vm.loadExpenses,
                )
              : vm.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.receipt_long_outlined,
                      title: 'No Expenses Found',
                      subtitle: 'No expense records have been issued for your room yet.',
                    )
                  : RefreshIndicator(
                      onRefresh: vm.loadExpenses,
                      color: DormMateColors.primary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        children: [
                          // Unpaid Overdue Action Banner
                          if (unpaidExpenses.isNotEmpty) ...[
                            FadeSlideEntry(
                              delay: const Duration(milliseconds: 30),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF003D6B), Color(0xFF0A588C)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF003D6B).withValues(alpha: 0.28),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${unpaidExpenses.length} Unpaid Bill${unpaidExpenses.length > 1 ? 's' : ''}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Total: ฿${unpaidExpenses.fold<double>(0, (s, e) => s + e.total).toStringAsFixed(0)} · Due Soon',
                                            style: const TextStyle(
                                              color: Color(0xFF80D8FF),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF003D6B),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () => _showUnpaidSelectionSheet(context, unpaidExpenses),
                                      icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                                      label: const Text(
                                        'Pay Now',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          // Latest month summary card
                          if (vm.currentMonthExpense != null) ...[
                            FadeSlideEntry(
                              delay: const Duration(milliseconds: 50),
                              child: ExpenseSummaryCard(expense: vm.currentMonthExpense!),
                            ),

                            // Breakdown glass card
                            FadeSlideEntry(
                              delay: const Duration(milliseconds: 120),
                              child: GlassCard(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Breakdown',
                                          style: DormMateTextStyles.sectionTitle,
                                        ),
                                        Flexible(
                                          child: Text(
                                            vm.currentMonthExpense!.displayMonth,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: DormMateColors.textTertiary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ExpenseBreakdownRow(
                                      icon: Icons.bolt_rounded,
                                      iconColor: DormMateColors.primary,
                                      iconBgColor: DormMateColors.primary.withValues(alpha: 0.1),
                                      label: 'Electricity',
                                      amount: vm.currentMonthExpense!.electricity,
                                    ),
                                    ExpenseBreakdownRow(
                                      icon: Icons.water_drop_outlined,
                                      iconColor: const Color(0xFF007AFF),
                                      iconBgColor: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                      label: 'Water',
                                      amount: vm.currentMonthExpense!.water,
                                    ),
                                    ExpenseBreakdownRow(
                                      icon: Icons.wifi_rounded,
                                      iconColor: const Color(0xFF34C759),
                                      iconBgColor: const Color(0xFF34C759).withValues(alpha: 0.1),
                                      label: 'Internet',
                                      amount: vm.currentMonthExpense!.internet,
                                    ),
                                    if (vm.currentMonthExpense!.other > 0)
                                      ExpenseBreakdownRow(
                                        icon: Icons.more_horiz_rounded,
                                        iconColor: DormMateColors.textSecondary,
                                        iconBgColor: DormMateColors.divider,
                                        label: 'Other',
                                        amount: vm.currentMonthExpense!.other,
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(color: DormMateColors.divider),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: DormMateColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '฿${vm.currentMonthExpense!.total.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: DormMateColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),
                          Text(
                            'History',
                            style: DormMateTextStyles.sectionTitle,
                          ),
                          const SizedBox(height: 10),

                          // History items
                          ...vm.expenses.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final exp = entry.value;
                            return FadeSlideEntry(
                              delay: Duration(milliseconds: 180 + idx * 40),
                              child: GlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                onTap: () => context.go('/expenses/${exp.id}'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exp.displayMonth,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: DormMateColors.textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            exp.dueDate != null ? 'Due: ${exp.dueDate}' : 'Monthly Bill',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: DormMateColors.textTertiary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '฿${exp.total.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: DormMateColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        StatusBadge(status: exp.paymentStatus),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: DormMateColors.textDisabled,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 96),
                        ],
                      ),
                    ),
    );
  }
}
