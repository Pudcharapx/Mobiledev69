import '../models/expense.dart';
import '../services/api_service.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<Expense> getExpenseDetail(int id);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ApiService _apiService;

  ExpenseRepositoryImpl(this._apiService);

  @override
  Future<List<Expense>> getExpenses() async {
    final data = await _apiService.getExpenses();
    if (data is List) {
      return data.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<Expense> getExpenseDetail(int id) async {
    final data = await _apiService.getExpenseDetail(id);
    return Expense.fromJson(data as Map<String, dynamic>);
  }
}
