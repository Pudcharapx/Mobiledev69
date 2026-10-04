import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_animations.dart';
import '../../widgets/promptpay_sheet.dart';
import '../../models/expense.dart';
import '../../models/feature_guide.dart';
import '../../widgets/feature_guide_sheet.dart';
import '../../widgets/neumorphic.dart';
import '../../core/localization/language_service.dart';
import '../../widgets/language_toggle_button.dart';

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
    final isThai = context.isThai;
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
                          isThai ? 'บิลค้างชำระ' : 'Unpaid Bills',
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
                          isThai ? 'ค้างชำระ ${unpaidExpenses.length} รายการ' : '${unpaidExpenses.length} Overdue',
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
                    isThai
                        ? 'เลือกรายการบิลด้านล่างเพื่อแสดง QR พร้อมเพย์และดำเนินการชำระเงิน'
                        : 'Select a bill below to view PromptPay QR and proceed with payment.',
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
                            billingMonth: isThai
                                ? 'บิลค้างชำระทั้งหมด (${unpaidExpenses.length} เดือน)'
                                : 'All Unpaid Bills (${unpaidExpenses.length} Months)',
                            totalAmount: totalAll,
                          );
                        },
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: Text(
                          isThai
                              ? 'ชำระบิลค้างทั้งหมด (฿${unpaidExpenses.fold<double>(0, (s, e) => s + e.total).toStringAsFixed(0)})'
                              : 'Pay All Unpaid (฿${unpaidExpenses.fold<double>(0, (s, e) => s + e.total).toStringAsFixed(0)})',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isThai = context.isThai;
    final unpaidExpenses = vm.expenses.where((e) => !e.isPaid).toList();

    return AnimatedOrbBackground(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            isThai ? 'ค่าใช้จ่าย' : 'Expenses',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: DormMateColors.textPrimary,
            ),
          ),
          actions: [
            LanguageToggleButton(isDark: isDark),
            IconButton(
              icon: const Icon(Icons.help_outline_rounded),
              tooltip: isThai ? 'ขั้นตอนการชำระเงิน' : 'Payment Guide',
              onPressed: () => showFeatureGuideSheet(context, FeatureGuide.paymentGuide),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: isThai ? 'สถิติการใช้พลังงาน' : 'Usage Analytics',
              onPressed: () => context.push('/expenses/analytics'),
            ),
            const SizedBox(width: 4),
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
                    ? EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        title: isThai ? 'ไม่พบข้อมูลค่าใช้จ่าย' : 'No Expenses Found',
                        subtitle: isThai ? 'ยังไม่มีรายการค่าใช้จ่ายที่ออกให้ห้องของคุณ' : 'No expense records have been issued for your room yet.',
                      )
                    : RefreshIndicator(
                        onRefresh: vm.loadExpenses,
                        color: DormMateColors.primary,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          children: [
                            // ── Unpaid Overdue Action Banner ──────────────────────
                            if (unpaidExpenses.isNotEmpty) ...[
                              FadeSlideEntry(
                                delay: const Duration(milliseconds: 30),
                                child: NeuContainer(
                                  isDark: isDark,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(18),
                                  borderRadius: 24,
                                  shadowIntensity: 0.9,
                                  bgColor: isDark ? const Color(0xFF1E2235) : Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Alert Header
                                      Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFFF5E62).withValues(alpha: 0.32),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.receipt_long_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        isThai
                                                            ? 'บิลค้างชำระ ${unpaidExpenses.length} รายการ'
                                                            : '${unpaidExpenses.length} Unpaid Bill${unpaidExpenses.length > 1 ? 's' : ''}',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w800,
                                                          color: DormMateColors.textPrimary,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: DormMateColors.statusErrorBg,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        isThai ? 'รอชำระ' : 'Overdue',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w700,
                                                          color: DormMateColors.statusErrorText,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  isThai
                                                      ? 'รวม: ฿${unpaidExpenses.fold<double>(0, (s, e) => s + e.total).toStringAsFixed(0)} · ครบกำหนดเร็วๆ นี้'
                                                      : 'Total: ฿${unpaidExpenses.fold<double>(0, (s, e) => s + e.total).toStringAsFixed(0)} · Due Soon',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: DormMateColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),
                                      Divider(color: DormMateColors.divider, height: 1),
                                      const SizedBox(height: 12),

                                      // Unpaid items section title
                                      Text(
                                        isThai ? 'รายการบิลที่ต้องชำระ' : 'Pending Invoices',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: DormMateColors.textTertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // List of unpaid bills
                                      ...unpaidExpenses.map((exp) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              showPromptPaySheet(
                                                context,
                                                billingMonth: exp.displayMonthLocale(isThai),
                                                totalAmount: exp.total,
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF262A3E) : const Color(0xFFF8FAFC),
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: isDark ? const Color(0xFF373D56) : const Color(0xFFE2E8F0),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 38,
                                                    height: 38,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF667EEA).withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: const Icon(
                                                      Icons.receipt_rounded,
                                                      color: Color(0xFF667EEA),
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          exp.displayMonthLocale(isThai),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w700,
                                                            color: DormMateColors.textPrimary,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          exp.dueDate != null
                                                              ? (isThai ? 'ครบกำหนด: ${exp.dueDate}' : 'Due: ${exp.dueDate}')
                                                              : (isThai ? 'ค่าบริการประจำเดือน' : 'Monthly fee'),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: DormMateColors.textTertiary,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          isThai
                                                              ? 'ไฟ ฿${exp.electricity.toStringAsFixed(0)} · น้ำ ฿${exp.water.toStringAsFixed(0)} · เน็ต ฿${exp.internet.toStringAsFixed(0)}'
                                                              : 'Elec ฿${exp.electricity.toStringAsFixed(0)} · Water ฿${exp.water.toStringAsFixed(0)} · Net ฿${exp.internet.toStringAsFixed(0)}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: DormMateColors.textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        '฿${exp.total.toStringAsFixed(0)}',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w800,
                                                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF003D6B),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF667EEA).withValues(alpha: 0.12),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons.qr_code_rounded,
                                                              size: 11,
                                                              color: Color(0xFF667EEA),
                                                            ),
                                                            const SizedBox(width: 3),
                                                            Text(
                                                              isThai ? 'สแกนจ่าย' : 'Pay QR',
                                                              style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.w700,
                                                                color: Color(0xFF667EEA),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),

                                      const SizedBox(height: 6),

                                      // Pay Now Action Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF667EEA),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () => _showUnpaidSelectionSheet(context, unpaidExpenses),
                                          icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                                          label: Text(
                                            isThai ? 'ชำระเงิน' : 'Pay Now',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            // ── Latest month summary card ─────────────────────────
                            if (vm.currentMonthExpense != null) ...[
                              FadeSlideEntry(
                                delay: const Duration(milliseconds: 50),
                                child: ExpenseSummaryCard(expense: vm.currentMonthExpense!),
                              ),

                              // ── Breakdown NeuContainer ────────────────────────
                              FadeSlideEntry(
                                delay: const Duration(milliseconds: 120),
                                child: NeuContainer(
                                  isDark: isDark,
                                  padding: const EdgeInsets.all(18),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  borderRadius: 24,
                                  shadowIntensity: 1.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isThai ? 'รายละเอียดค่าใช้จ่าย' : 'Breakdown',
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
                                        label: isThai ? 'ค่าไฟฟ้า' : 'Electricity',
                                        amount: vm.currentMonthExpense!.electricity,
                                      ),
                                      ExpenseBreakdownRow(
                                        icon: Icons.water_drop_outlined,
                                        iconColor: const Color(0xFF007AFF),
                                        iconBgColor: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                        label: isThai ? 'ค่าน้ำประปา' : 'Water',
                                        amount: vm.currentMonthExpense!.water,
                                      ),
                                      ExpenseBreakdownRow(
                                        icon: Icons.wifi_rounded,
                                        iconColor: const Color(0xFF34C759),
                                        iconBgColor: const Color(0xFF34C759).withValues(alpha: 0.1),
                                        label: isThai ? 'ค่าอินเทอร์เน็ต' : 'Internet',
                                        amount: vm.currentMonthExpense!.internet,
                                      ),
                                      if (vm.currentMonthExpense!.other > 0)
                                        ExpenseBreakdownRow(
                                          icon: Icons.more_horiz_rounded,
                                          iconColor: DormMateColors.textSecondary,
                                          iconBgColor: DormMateColors.divider,
                                          label: isThai ? 'อื่นๆ' : 'Other',
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
                                            isThai ? 'ยอดรวม' : 'Total',
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
                              isThai ? 'ประวัติบิล' : 'History',
                              style: DormMateTextStyles.sectionTitle,
                            ),
                            const SizedBox(height: 10),

                            // ── History items ─────────────────────────────────────
                            ...vm.expenses.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final exp = entry.value;
                              return FadeSlideEntry(
                                delay: Duration(milliseconds: 180 + idx * 40),
                                child: NeuContainer(
                                  isDark: isDark,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  borderRadius: 20,
                                  shadowIntensity: 1.0,
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
                                              exp.dueDate != null
                                                  ? (isThai ? 'ครบกำหนด: ${exp.dueDate}' : 'Due: ${exp.dueDate}')
                                                  : (isThai ? 'บิลรายเดือน' : 'Monthly Bill'),
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
      ),
    );
  }
}
