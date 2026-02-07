import 'package:intl/intl.dart';

import '../../data/models/currency_model.dart';



// Classe utilitaire pour formatage supplémentaire
class CurrencyFormatter {
  /// Formate un montant selon la devise sélectionnée
  static String format(double amount, Currency currency) {
    return currency.format(amount);
  }

  /// Formate un montant avec séparateur de milliers (sans symbole)
  static String formatNumber(double amount) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return formatter.format(amount);
  }

  /// Formate un montant compact (1K, 1M, etc.)
  static String formatCompact(double amount, Currency currency) {
    String compactValue;

    if (amount >= 1000000) {
      compactValue = '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      compactValue = '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      compactValue = amount.toStringAsFixed(0);
    }

    return '$compactValue ${currency.symbol}';
  }

  /// Parse un string en double (pour les champs de saisie)
  static double? parse(String value) {
    // Enlever les espaces et remplacer la virgule par un point
    final cleaned = value.replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  /// Formate pour les inputs (avec espaces pour lisibilité)
  static String formatForInput(double amount) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return formatter.format(amount).replaceAll(',', ' ');
  }
}