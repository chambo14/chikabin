import 'package:hive_flutter/hive_flutter.dart';
import '../models/envelope_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class DatabaseService {
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String settingsBox = 'settings';
  static const String envelopesBox = 'envelopes';

  Future<void> init() async {
    await Hive.initFlutter();

    // Ouvrir toutes les boxes
    await Hive.openBox(transactionsBox);
    await Hive.openBox(categoriesBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(envelopesBox);

    // Initialiser les catégories par défaut
    await _initDefaultCategories();
  }

  Future<void> _initDefaultCategories() async {
    final box = Hive.box(categoriesBox);
    if (box.isEmpty) {
      for (var category in [...DefaultCategories.expenses, ...DefaultCategories.income]) {
        await box.put(category.id, category.toJson());
      }
    }
  }

  // ========== TRANSACTIONS ==========
  Future<void> addTransaction(TransactionModel transaction) async {
    final box = Hive.box(transactionsBox);
    await box.put(transaction.id, transaction.toJson());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final box = Hive.box(transactionsBox);
    await box.put(transaction.id, transaction.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    final box = Hive.box(transactionsBox);
    await box.delete(id);
  }

  List<TransactionModel> getAllTransactions() {
    final box = Hive.box(transactionsBox);
    return box.values
        .map((json) => TransactionModel.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ========== CATÉGORIES ========== ← NOUVEAU
  List<CategoryModel> getAllCategories() {
    final box = Hive.box(categoriesBox);
    return box.values
        .map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    final box = Hive.box(categoriesBox);
    await box.put(category.id, category.toJson());
  }

  Future<void> updateCategory(CategoryModel category) async {
    final box = Hive.box(categoriesBox);
    await box.put(category.id, category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    final box = Hive.box(categoriesBox);
    await box.delete(id);
  }

  // ========== ENVELOPPES ========== ← NOUVEAU
  List<EnvelopeModel> getAllEnvelopes() {
    final box = Hive.box(envelopesBox);
    return box.values
        .map((json) => EnvelopeModel.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> addEnvelope(EnvelopeModel envelope) async {
    final box = Hive.box(envelopesBox);
    await box.put(envelope.id, envelope.toJson());
  }

  Future<void> updateEnvelope(EnvelopeModel envelope) async {
    final box = Hive.box(envelopesBox);
    await box.put(envelope.id, envelope.toJson());
  }

  Future<void> deleteEnvelope(String id) async {
    final box = Hive.box(envelopesBox);
    await box.delete(id);
  }

  // Calculer la carte virtuelle (revenus non alloués)
  double getVirtualCardBalance() {
    final transactions = getAllTransactions();
    final envelopes = getAllEnvelopes();

    // Total revenus
    double totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);

    // Total alloué aux enveloppes
    double totalAllocated = envelopes
        .fold(0, (sum, e) => sum + e.currentAmount);

    // Carte virtuelle = revenus - alloué
    return totalIncome - totalAllocated;
  }

  // Allouer montant à une enveloppe depuis carte virtuelle
  Future<bool> allocateToEnvelope(String envelopeId, double amount) async {
    final virtualCardBalance = getVirtualCardBalance();

    // Vérifier si assez de fonds
    if (amount > virtualCardBalance) {
      return false; // Pas assez de fonds
    }

    final box = Hive.box(envelopesBox);
    final envelopeJson = box.get(envelopeId);
    if (envelopeJson == null) return false;

    final envelope = EnvelopeModel.fromJson(Map<String, dynamic>.from(envelopeJson));
    final updated = envelope.copyWith(
      currentAmount: envelope.currentAmount + amount,
    );

    await box.put(envelopeId, updated.toJson());
    return true;
  }

  Future<bool> deductFromEnvelope(String envelopeId, double amount) async {
    final box = Hive.box(envelopesBox);
    final envelopeJson = box.get(envelopeId);
    if (envelopeJson == null) return false;

    final envelope = EnvelopeModel.fromJson(Map<String, dynamic>.from(envelopeJson));

    final updated = envelope.copyWith(
      spentAmount: envelope.spentAmount + amount,
    );

    await box.put(envelopeId, updated.toJson());
    return true;
  }
// Réallouer entre enveloppes
  Future<bool> transferBetweenEnvelopes(
      String fromEnvelopeId,
      String toEnvelopeId,
      double amount,
      ) async {
    final box = Hive.box(envelopesBox);

    final fromJson = box.get(fromEnvelopeId);
    final toJson = box.get(toEnvelopeId);
    if (fromJson == null || toJson == null) return false;

    final fromEnvelope = EnvelopeModel.fromJson(Map<String, dynamic>.from(fromJson));
    final toEnvelope = EnvelopeModel.fromJson(Map<String, dynamic>.from(toJson));

    // Vérifier disponibilité
    if (fromEnvelope.availableAmount < amount) return false;

    final updatedFrom = fromEnvelope.copyWith(
      currentAmount: fromEnvelope.currentAmount - amount,
    );
    final updatedTo = toEnvelope.copyWith(
      currentAmount: toEnvelope.currentAmount + amount,
    );
    await box.put(fromEnvelopeId, updatedFrom.toJson());
    await box.put(toEnvelopeId, updatedTo.toJson());
    return true;
  }
  // Réinitialiser enveloppes (nouveau mois)
  Future<void> resetEnvelopesForNewMonth() async {
    final box = Hive.box(envelopesBox);
    final envelopes = getAllEnvelopes();

    for (var envelope in envelopes) {
      double newAmount = 0;

      // Si rollover activé, garder le reste
      if (envelope.rollover) {
        newAmount = envelope.availableAmount;
      }

      // Si auto-refill activé, ajouter le target
      if (envelope.autoRefill) {
        newAmount += envelope.targetAmount;
      }

      final updated = envelope.copyWith(
        currentAmount: newAmount,
        spentAmount: 0,
        lastRefillDate: DateTime.now(),
      );

      await box.put(envelope.id, updated.toJson());
    }
  }




  // ========== PARAMÈTRES ==========
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(settingsBox);
    await box.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = Hive.box(settingsBox);
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> deleteSetting(String key) async {
    final box = Hive.box(settingsBox);
    await box.delete(key);
  }

  // ========== UTILITAIRES ==========
  Future<void> clearAllData() async {
    final transBox = Hive.box(transactionsBox);
    final catBox = Hive.box(categoriesBox);
    final envBox = Hive.box(envelopesBox); // ← NOUVEAU
    final setBox = Hive.box(settingsBox);

    await transBox.clear();
    await catBox.clear();
    await envBox.clear(); // ← NOUVEAU
    await setBox.clear();

    // Réinitialiser les catégories par défaut
    await _initDefaultCategories();
  }

  Map<String, int> getStats() {
    final transBox = Hive.box(transactionsBox);
    final catBox = Hive.box(categoriesBox);
    final envBox = Hive.box(envelopesBox); // ← NOUVEAU

    return {
      'transactions': transBox.length,
      'categories': catBox.length,
      'envelopes': envBox.length, // ← NOUVEAU
    };
  }

  Future<void> close() async {
    await Hive.close();
  }
}