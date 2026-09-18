import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/expense.dart';
import 'package:project/viewmodels/expense_viewmodel.dart';
import '../fake_repositories/fake_expense_repository.dart';

void main() {
  group('ExpenseViewModel Unit Tests', () {
    late FakeExpenseRepository fakeRepo;
    late ExpenseViewModel viewModel;

    final sampleExpenses = [
      const Expense(
        id: 1,
        billingMonth: '2026-09',
        electricity: 620,
        water: 180,
        internet: 300,
        other: 0,
        total: 1100,
        paymentStatus: 'Unpaid',
        dueDate: '2026-09-30',
        createdAt: '2026-09-01T00:00:00Z',
      ),
      const Expense(
        id: 2,
        billingMonth: '2026-08',
        electricity: 540,
        water: 160,
        internet: 300,
        other: 50,
        total: 1050,
        paymentStatus: 'Paid',
        dueDate: '2026-08-31',
        createdAt: '2026-08-01T00:00:00Z',
      ),
    ];

    setUp(() {
      fakeRepo = FakeExpenseRepository(initialExpenses: List.from(sampleExpenses));
      viewModel = ExpenseViewModel(fakeRepo);
    });

    test('loadExpenses populates expense list and currentMonthExpense', () async {
      await viewModel.loadExpenses();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.expenses.length, equals(2));
      expect(viewModel.currentMonthExpense?.billingMonth, equals('2026-09'));
      expect(viewModel.currentMonthExpense?.total, equals(1100));
      expect(viewModel.currentMonthExpense?.isPaid, isFalse);
    });

    test('selectExpense loads detail successfully', () async {
      await viewModel.selectExpense(2);

      expect(viewModel.selectedExpense, isNotNull);
      expect(viewModel.selectedExpense?.id, equals(2));
      expect(viewModel.selectedExpense?.isPaid, isTrue);
    });

    test('loadExpenses handles error state gracefully', () async {
      fakeRepo.shouldThrowError = true;

      await viewModel.loadExpenses();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.expenses, isEmpty);
    });
  });
}
