import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/currency_model.dart';

class CurrencyNotifier extends StateNotifier<Currency> {
  static const String _currencyKey = 'selected_currency';

  CurrencyNotifier() : super(Currency.fcfa) {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      // ✅ Vérifier si la box existe, sinon l'ouvrir
      Box box;
      if (Hive.isBoxOpen('settings')) {
        box = Hive.box('settings');
      } else {
        box = await Hive.openBox('settings');
      }

      final savedCurrency = box.get(_currencyKey, defaultValue: 'fcfa');

      state = Currency.values.firstWhere(
            (c) => c.name == savedCurrency,
        orElse: () => Currency.fcfa,
      );
    } catch (e) {
      // ✅ En cas d'erreur, garder la devise par défaut
      print('Erreur lors du chargement de la devise: $e');
      state = Currency.fcfa;
    }
  }

  Future<void> setCurrency(Currency currency) async {
    try {
      state = currency;

      // ✅ Vérifier si la box existe, sinon l'ouvrir
      Box box;
      if (Hive.isBoxOpen('settings')) {
        box = Hive.box('settings');
      } else {
        box = await Hive.openBox('settings');
      }

      await box.put(_currencyKey, currency.name);
    } catch (e) {
      // ✅ En cas d'erreur, afficher dans la console
      print('Erreur lors de la sauvegarde de la devise: $e');
    }
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>(
      (ref) => CurrencyNotifier(),
);