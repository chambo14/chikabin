import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database_service.dart';
import '../models/envelope_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart'; // ← Ajouté

final databaseServiceProvider = Provider((ref) => DatabaseService());

// ========== TRANSACTIONS ==========
final transactionsProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>(
      (ref) => TransactionNotifier(ref.read(databaseServiceProvider)),
);

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final DatabaseService _databaseService;

  TransactionNotifier(this._databaseService) : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = _databaseService.getAllTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _databaseService.addTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _databaseService.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _databaseService.deleteTransaction(id);
    await loadTransactions();
  }
}

// ========== CATÉGORIES ========== ← NOUVEAU
final categoryNotifierProvider = StateNotifierProvider<CategoryNotifier, List<CategoryModel>>(
      (ref) => CategoryNotifier(ref.read(databaseServiceProvider)),
);

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final DatabaseService _databaseService;

  CategoryNotifier(this._databaseService) : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = _databaseService.getAllCategories();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _databaseService.addCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _databaseService.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _databaseService.deleteCategory(id);
    await loadCategories();
  }
}

// Provider pour compatibilité (garde l'ancien aussi)
final categoriesProvider = Provider((ref) {
  return ref.watch(categoryNotifierProvider);
});

// ========== ENVELOPPES ========== ← NOUVEAU
final envelopeNotifierProvider = StateNotifierProvider<EnvelopeNotifier, List<EnvelopeModel>>(
      (ref) => EnvelopeNotifier(ref.read(databaseServiceProvider)),
);

class EnvelopeNotifier extends StateNotifier<List<EnvelopeModel>> {
  final DatabaseService _databaseService;

  EnvelopeNotifier(this._databaseService) : super([]) {
    loadEnvelopes();
  }

  Future<void> loadEnvelopes() async {
    state = _databaseService.getAllEnvelopes();
  }

  Future<void> addEnvelope(EnvelopeModel envelope) async {
    await _databaseService.addEnvelope(envelope);
    await loadEnvelopes();
  }

  Future<void> updateEnvelope(EnvelopeModel envelope) async {
    await _databaseService.updateEnvelope(envelope);
    await loadEnvelopes();
  }

  Future<void> deleteEnvelope(String id) async {
    await _databaseService.deleteEnvelope(id);
    await loadEnvelopes();
  }

  Future<bool> allocateToEnvelope(String envelopeId, double amount) async {
    final success = await _databaseService.allocateToEnvelope(envelopeId, amount);
    if (success) await loadEnvelopes();
    return success;
  }

  Future<bool> deductFromEnvelope(String envelopeId, double amount) async {
    final success = await _databaseService.deductFromEnvelope(envelopeId, amount);
    if (success) await loadEnvelopes();
    return success;
  }

  Future<bool> transferBetweenEnvelopes(String from, String to, double amount) async {
    final success = await _databaseService.transferBetweenEnvelopes(from, to, amount);
    if (success) await loadEnvelopes();
    return success;
  }

  Future<void> resetForNewMonth() async {
    await _databaseService.resetEnvelopesForNewMonth();
    await loadEnvelopes();
  }
}

// Provider pour carte virtuelle
final virtualCardProvider = Provider<double>((ref) {
  ref.watch(envelopeNotifierProvider); // Re-calculer si enveloppes changent
  ref.watch(transactionsProvider); // Re-calculer si transactions changent
  return ref.read(databaseServiceProvider).getVirtualCardBalance();
});

// Provider pour compatibilité
final envelopesProvider = Provider((ref) {
  return ref.watch(envelopeNotifierProvider);
});

// ========== STATISTIQUES ==========
final statsProvider = Provider.family<Map<String, double>, DateTime>((ref, month) {
  final transactions = ref.watch(transactionsProvider);

  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

  final monthTransactions = transactions.where((t) =>
  t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
      t.date.isBefore(endOfMonth.add(const Duration(seconds: 1)))
  ).toList();

  double income = 0;
  double expense = 0;

  for (var transaction in monthTransactions) {
    if (transaction.type == TransactionType.income) {
      income += transaction.amount;
    } else {
      expense += transaction.amount;
    }
  }

  return {
    'income': income,
    'expense': expense,
    'balance': income - expense,
  };
});

final yearStatsProvider = Provider.family<Map<String, double>, int>((ref, year) {
  final transactions = ref.watch(transactionsProvider);

  final startOfYear = DateTime(year, 1, 1);
  final endOfYear = DateTime(year, 12, 31, 23, 59, 59);

  final yearTransactions = transactions.where((t) =>
  t.date.isAfter(startOfYear.subtract(const Duration(seconds: 1))) &&
      t.date.isBefore(endOfYear.add(const Duration(seconds: 1)))
  ).toList();

  double income = 0;
  double expense = 0;

  for (var transaction in yearTransactions) {
    if (transaction.type == TransactionType.income) {
      income += transaction.amount;
    } else {
      expense += transaction.amount;
    }
  }

  return {
    'income': income,
    'expense': expense,
    'balance': income - expense,
  };
});

final availableYearsProvider = Provider<List<int>>((ref) {
  final transactions = ref.watch(transactionsProvider);

  if (transactions.isEmpty) {
    return [DateTime.now().year];
  }

  final years = transactions.map((t) => t.date.year).toSet().toList();
  years.sort((a, b) => b.compareTo(a));

  return years;


});