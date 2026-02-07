import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../local/database_service.dart';

class BackupService {
  final DatabaseService _dbService = DatabaseService();

  // Export des données
  Future<Map<String, dynamic>> exportData() async {
    final transactionsBox = Hive.box(DatabaseService.transactionsBox);
    final categoriesBox = Hive.box(DatabaseService.categoriesBox);
    final settingsBox = Hive.box(DatabaseService.settingsBox);

    return {
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'transactions': transactionsBox.values.toList(),
      'categories': categoriesBox.values.toList(),
      'settings': settingsBox.toMap(),
    };
  }

  // Sauvegarder vers un fichier
  Future<String> saveBackupToFile() async {
    final data = await exportData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final fileName = 'chikabin_backup_$timestamp.json';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(jsonString);

    return file.path;
  }

  // Partager le backup
  Future<void> shareBackup() async {
    final filePath = await saveBackupToFile();
    await Share.shareXFiles([XFile(filePath)], text: 'Sauvegarde ChikaBin');
  }

  // Restaurer depuis JSON
  Future<bool> restoreFromJson(Map<String, dynamic> data) async {
    try {
      final transactionsBox = Hive.box(DatabaseService.transactionsBox);
      final categoriesBox = Hive.box(DatabaseService.categoriesBox);
      final settingsBox = Hive.box(DatabaseService.settingsBox);

      // Vider les données existantes
      await transactionsBox.clear();
      await categoriesBox.clear();
      await settingsBox.clear();

      // Restaurer les transactions
      if (data['transactions'] != null) {
        for (var transactionJson in data['transactions']) {
          final transaction = TransactionModel.fromJson(
            Map<String, dynamic>.from(transactionJson),
          );
          await transactionsBox.put(transaction.id, transactionJson);
        }
      }

      // Restaurer les catégories
      if (data['categories'] != null) {
        for (var categoryJson in data['categories']) {
          final category = CategoryModel.fromJson(
            Map<String, dynamic>.from(categoryJson),
          );
          await categoriesBox.put(category.id, categoryJson);
        }
      }

      // Restaurer les paramètres
      if (data['settings'] != null) {
        for (var entry in (data['settings'] as Map).entries) {
          await settingsBox.put(entry.key, entry.value);
        }
      }

      return true;
    } catch (e) {
      print('Erreur lors de la restauration: $e');
      return false;
    }
  }

  // Restaurer depuis un fichier
  Future<bool> restoreFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      return await restoreFromJson(data);
    } catch (e) {
      print('Erreur lors de la lecture du fichier: $e');
      return false;
    }
  }

  // Obtenir les statistiques du backup
  Future<Map<String, int>> getBackupStats() async {
    return _dbService.getStats();
  }
}