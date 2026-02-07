import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'envelope_model.freezed.dart';
part 'envelope_model.g.dart';

@freezed
class EnvelopeModel with _$EnvelopeModel {
  const EnvelopeModel._();

  const factory EnvelopeModel({
    required String id,
    required String name,
    required String icon,
    required String colorHex,
    required double targetAmount, // Montant cible mensuel
    required double currentAmount, // Montant actuel dans l'enveloppe
    required double spentAmount, // Montant dépensé ce mois
    @Default(false) bool autoRefill, // Remplissage auto chaque mois
    @Default(false) bool rollover, // Reporter le reste sur mois suivant
    String? categoryId, // Lien optionnel avec une catégorie
    DateTime? lastRefillDate,
  }) = _EnvelopeModel;

  factory EnvelopeModel.fromJson(Map<String, dynamic> json) =>
      _$EnvelopeModelFromJson(json);

  // Getters calculés
  Color get color => Color(int.parse('0xFF${colorHex.substring(1)}'));

  IconData get iconData {
    final iconMap = {
      'home': Icons.home,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'local_hospital': Icons.local_hospital,
      'shopping_cart': Icons.shopping_cart,
      'school': Icons.school,
      'fitness_center': Icons.fitness_center,
      'movie': Icons.movie,
      'savings': Icons.savings,
      'phone': Icons.phone,
      'local_gas_station': Icons.local_gas_station,
      'credit_card': Icons.credit_card,
      'lightbulb': Icons.lightbulb,
      'pets': Icons.pets,
      'child_care': Icons.child_care,
    };
    return iconMap[icon] ?? Icons.account_balance_wallet;
  }

  double get remainingAmount => targetAmount - currentAmount;
  double get availableAmount => currentAmount - spentAmount;
  double get percentageFilled => targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
  double get percentageSpent => currentAmount > 0 ? (spentAmount / currentAmount) * 100 : 0;
  bool get isOverBudget => spentAmount > currentAmount;
  bool get isNearlyEmpty => availableAmount < (targetAmount * 0.2); // < 20%
}

// Enveloppes par défaut suggérées
class DefaultEnvelopes {
  static final List<Map<String, dynamic>> suggestions = [
    {
      'name': 'Loyer',
      'icon': 'home',
      'colorHex': '#FF5722',
      'targetAmount': 150000.0,
    },
    {
      'name': 'Nourriture',
      'icon': 'restaurant',
      'colorHex': '#4CAF50',
      'targetAmount': 80000.0,
    },
    {
      'name': 'Transport',
      'icon': 'directions_car',
      'colorHex': '#2196F3',
      'targetAmount': 50000.0,
    },
    {
      'name': 'Santé',
      'icon': 'local_hospital',
      'colorHex': '#F44336',
      'targetAmount': 30000.0,
    },
    {
      'name': 'Épargne',
      'icon': 'savings',
      'colorHex': '#FFB300',
      'targetAmount': 100000.0,
    },
    {
      'name': 'Shopping',
      'icon': 'shopping_cart',
      'colorHex': '#9C27B0',
      'targetAmount': 40000.0,
    },
    {
      'name': 'Loisirs',
      'icon': 'movie',
      'colorHex': '#00BCD4',
      'targetAmount': 30000.0,
    },
    {
      'name': 'Éducation',
      'icon': 'school',
      'colorHex': '#3F51B5',
      'targetAmount': 50000.0,
    },
  ];
}