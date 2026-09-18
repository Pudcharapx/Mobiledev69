import 'package:project/models/expense.dart';
import 'package:project/repositories/expense_repository.dart';

class FakeExpenseRepository implements ExpenseRepository {
  List<Expense> expenses;
  bool shouldThrowError;

  FakeExpenseRepository({
    List<Expense>? initialExpenses,
    this.shouldThrowError = false,
  }) : expenses = initialExpenses ?? [];

  @override
  Future<List<Expense>> getExpenses() async {
    if (shouldThrowError) throw Exception('API Error');
    return List.from(expenses);
  }

  @override
  Future<Expense> getExpenseDetail(int id) async {
    if (shouldThrowError) throw Exception('API Error');
    return expenses.firstWhere((e) => e.id == id);
  }
}
