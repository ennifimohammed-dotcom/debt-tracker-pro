import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/database_service.dart';

enum SortType { date, amount, name }

class DebtProvider extends ChangeNotifier {
  List<Debt> _all = [];
  String _search = '';
  SortType _sort = SortType.date;
  bool _showSettled = false;

  List<Debt> get all => _filtered();
  List<Debt> get lent =>
      _filtered().where((d) => d.type == 'lend' && !d.isSettled).toList();
  List<Debt> get borrowed =>
      _filtered().where((d) => d.type == 'borrow' && !d.isSettled).toList();
  List<Debt> get settled => _all.where((d) => d.isSettled).toList();
  List<Debt> get overdue =>
      _all.where((d) => d.isOverdue).toList();
  SortType get sort => _sort;
  bool get showSettled => _showSettled;

  double get totalLent =>
      lent.fold(0.0, (double s, d) => s + d.remainingAmount);
  double get totalBorrowed =>
      borrowed.fold(0.0, (double s, d) => s + d.remainingAmount);
  double get netBalance => totalLent - totalBorrowed;

  int get lentCount => lent.length;
  int get borrowedCount => borrowed.length;
  int get overdueCount => overdue.length;

  List<Debt> _filtered() {
    var list = List<Debt>.from(_all);
    if (!_showSettled) list = list.where((d) => !d.isSettled).toList();
    if (_search.isNotEmpty) {
      list = list
          .where((d) =>
              d.name.contains(_search) || d.phone.contains(_search))
          .toList();
    }
    switch (_sort) {
      case SortType.date:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.amount:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortType.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }

  Future<void> load() async {
    _all = await DatabaseService().getAll();
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    await DatabaseService().insert(debt);
    await load();
  }

  Future<void> updateDebt(Debt debt) async {
    await DatabaseService().update(debt);
    await load();
  }

  Future<void> deleteDebt(int id) async {
    await DatabaseService().delete(id);
    await load();
  }

  Future<void> settleDebt(Debt debt) async {
    await DatabaseService().update(
      debt.copyWith(isSettled: true, paidAmount: debt.amount),
    );
    await load();
  }

  Future<void> addPayment(Debt debt, double amount) async {
    final newPaid =
        (debt.paidAmount + amount).clamp(0.0, debt.amount);
    await DatabaseService().update(
      debt.copyWith(
        paidAmount: newPaid,
        isSettled: newPaid >= debt.amount,
      ),
    );
    await load();
  }

  Future<void> deleteAll() async {
    await DatabaseService().deleteAll();
    await load();
  }

  void setSearch(String q) {
    _search = q;
    notifyListeners();
  }

  void setSort(SortType s) {
    _sort = s;
    notifyListeners();
  }

  void toggleSettled() {
    _showSettled = !_showSettled;
    notifyListeners();
  }
}
