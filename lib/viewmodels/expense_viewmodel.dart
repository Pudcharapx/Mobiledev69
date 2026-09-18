import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Expense> _expenses = [];
  Expense? _selectedExpense;

  ExpenseViewModel(this._repository);

  bool get isLoading => _isLoading;
  bool get isEmpty => !_isLoading && _expenses.isEmpty;
  String? get errorMessage => _errorMessage;
  List<Expense> get expenses => _expenses;
  Expense? get currentMonthExpense => _expenses.isNotEmpty ? _expenses.first : null;
  Expense? get selectedExpense => _selectedExpense;

  Future<void> loadExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _repository.getExpenses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load expenses.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectExpense(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedExpense = await _repository.getExpenseDetail(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load expense details.';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedExpense = null;
    notifyListeners();
  }
}
