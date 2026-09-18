import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/models/expense.dart';
import 'package:project/viewmodels/expense_viewmodel.dart';
import 'package:project/views/expenses/expense_detail_screen.dart';
import '../fake_repositories/fake_expense_repository.dart';

void main() {
  testWidgets('ExpenseDetailScreen displays PromptPay button and opens PromptPay sheet with QR', (tester) async {
    final fakeRepo = FakeExpenseRepository(
      initialExpenses: [
        const Expense(
          id: 1,
          billingMonth: '2026-09',
          electricity: 450,
          water: 120,
          internet: 300,
          other: 0,
          total: 870,
          dueDate: '2026-09-25',
          paymentStatus: 'Unpaid',
          createdAt: '2026-09-01T00:00:00Z',
        ),
      ],
    );
    final vm = ExpenseViewModel(fakeRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ExpenseViewModel>.value(
          value: vm,
          child: const ExpenseDetailScreen(expenseId: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify expense header and breakdown
    expect(find.text('Expense Details'), findsOneWidget);
    expect(find.text('฿870'), findsNWidgets(2)); // Header amount + Grand Total

    // Verify PromptPay action button exists
    expect(find.text('Pay via PromptPay QR (สแกนจ่ายพร้อมเพย์)'), findsOneWidget);

    // Scroll and tap the PromptPay button
    await tester.ensureVisible(find.text('Pay via PromptPay QR (สแกนจ่ายพร้อมเพย์)'));
    await tester.tap(find.text('Pay via PromptPay QR (สแกนจ่ายพร้อมเพย์)'));
    await tester.pumpAndSettle();

    // Verify PromptPay Bottom Sheet opened
    expect(find.text('PROMPTPAY'), findsOneWidget);
    expect(find.text('พร้อมเพย์'), findsOneWidget);
    expect(find.text('PromptPay ID: 089-123-4567'), findsOneWidget);
    expect(find.text('Save QR'), findsOneWidget);
    expect(find.text('Attach Slip'), findsOneWidget);

    // Verify Attach Slip button taps and displays confirmation
    await tester.tap(find.text('Attach Slip'));
    await tester.pumpAndSettle();
    expect(find.text('Payment slip uploaded! Dorm staff will verify.'), findsOneWidget);
  });
}
