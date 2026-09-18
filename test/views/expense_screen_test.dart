import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/models/expense.dart';
import 'package:project/viewmodels/expense_viewmodel.dart';
import 'package:project/views/expenses/expense_screen.dart';
import '../fake_repositories/fake_expense_repository.dart';

void main() {
  testWidgets('ExpenseScreen shows Pay Now banner when unpaid expenses exist, and opens selection & PromptPay sheet without overflow', (tester) async {
    // Set small screen size to rigorously test against overflow
    tester.view.physicalSize = const Size(360 * 2, 640 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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
        const Expense(
          id: 2,
          billingMonth: '2026-08',
          electricity: 400,
          water: 100,
          internet: 300,
          other: 0,
          total: 800,
          dueDate: '2026-08-25',
          paymentStatus: 'Unpaid',
          createdAt: '2026-08-01T00:00:00Z',
        ),
        const Expense(
          id: 3,
          billingMonth: '2026-07',
          electricity: 350,
          water: 110,
          internet: 300,
          other: 0,
          total: 760,
          dueDate: '2026-07-25',
          paymentStatus: 'Paid',
          createdAt: '2026-07-01T00:00:00Z',
        ),
      ],
    );
    final vm = ExpenseViewModel(fakeRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ExpenseViewModel>.value(
          value: vm,
          child: const ExpenseScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Expenses'), findsOneWidget);

    // Verify Unpaid Banner appears
    expect(find.text('2 Unpaid Bills'), findsOneWidget);
    expect(find.text('Total: ฿1670 · Due Soon'), findsOneWidget);
    expect(find.text('Pay Now'), findsOneWidget);

    // Tap 'Pay Now' to open unpaid bills selection sheet
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();

    // Verify Unpaid Selection Sheet is open
    expect(find.text('Unpaid Bills'), findsOneWidget);
    expect(find.text('2 Overdue'), findsOneWidget);
    expect(find.text('Pay All Unpaid (฿1670)'), findsOneWidget);

    // Tap on the single bill item (September 2026) in the selection bottom sheet
    await tester.tap(find.widgetWithText(InkWell, 'September 2026'));
    await tester.pumpAndSettle();

    // Verify PromptPay Sheet opened with correct details
    expect(find.text('PROMPTPAY'), findsOneWidget);
    expect(find.text('฿870'), findsWidgets);
    expect(find.text('PromptPay ID: 089-123-4567'), findsOneWidget);
    expect(find.text('Attach Slip'), findsOneWidget);

    // Verify no RenderFlex overflow
    expect(tester.takeException(), isNull);
  });

  testWidgets('ExpenseScreen tapping Pay All Unpaid opens PromptPay sheet with total sum', (tester) async {
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
        const Expense(
          id: 2,
          billingMonth: '2026-08',
          electricity: 400,
          water: 100,
          internet: 300,
          other: 0,
          total: 800,
          dueDate: '2026-08-25',
          paymentStatus: 'Unpaid',
          createdAt: '2026-08-01T00:00:00Z',
        ),
      ],
    );
    final vm = ExpenseViewModel(fakeRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ExpenseViewModel>.value(
          value: vm,
          child: const ExpenseScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap 'Pay Now'
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();

    // Tap 'Pay All Unpaid (฿1670)'
    await tester.tap(find.text('Pay All Unpaid (฿1670)'));
    await tester.pumpAndSettle();

    // Verify PromptPay opened with All Unpaid Bills title and total
    expect(find.text('PROMPTPAY'), findsOneWidget);
    expect(find.text('฿1670'), findsOneWidget);
    expect(find.text('Billing: All Unpaid Bills (2 Months)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ExpenseScreen does not show Pay Now banner when all expenses are paid', (tester) async {
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
          paymentStatus: 'Paid',
          createdAt: '2026-09-01T00:00:00Z',
        ),
      ],
    );
    final vm = ExpenseViewModel(fakeRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ExpenseViewModel>.value(
          value: vm,
          child: const ExpenseScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Banner should NOT be visible
    expect(find.text('Pay Now'), findsNothing);
    expect(find.text('Unpaid Bills'), findsNothing);
    expect(find.text('History'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
