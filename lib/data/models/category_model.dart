import 'package:chikabin/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const CategoryModel._();

  const factory CategoryModel({
    required String id,
    required String name,
    required String icon,
    required String colorHex,
    required TransactionType type,
    @Default(false) bool isDefault, // ← NOUVEAU : indique si c'est une catégorie par défaut
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  // Méthode pour obtenir la couleur
  Color get color => Color(int.parse('0xFF${colorHex.substring(1)}'));

  // Méthode pour obtenir l'icône
  IconData get iconData {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'local_hospital': Icons.local_hospital,
      'sports_esports': Icons.sports_esports,
      'account_balance_wallet': Icons.account_balance_wallet,
      'work': Icons.work,
      'shopping_cart': Icons.shopping_cart,
      'school': Icons.school,
      'fitness_center': Icons.fitness_center,
      'phone': Icons.phone,
      'local_gas_station': Icons.local_gas_station,
      'restaurant_menu': Icons.restaurant_menu,
      'coffee': Icons.coffee,
      'movie': Icons.movie,
      'pets': Icons.pets,
      'card_giftcard': Icons.card_giftcard,
      'business': Icons.business,
      'attach_money': Icons.attach_money,
      'trending_up': Icons.trending_up,
      'face': Icons.face,
      'content_cut': Icons.content_cut,
    };
    return iconMap[icon] ?? Icons.category;
  }
}

// Catégories par défaut
class DefaultCategories {
  static final List<CategoryModel> expenses = [
    const CategoryModel(
      id: '1',
      name: 'Alimentation',
      icon: 'restaurant',
      colorHex: '#FF6B6B',
      type: TransactionType.expense,
      isDefault: true, // ← Ajouté
    ),
    const CategoryModel(
      id: '2',
      name: 'Transport',
      icon: 'directions_car',
      colorHex: '#4ECDC4',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '3',
      name: 'Logement',
      icon: 'home',
      colorHex: '#45B7D1',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '4',
      name: 'Santé',
      icon: 'local_hospital',
      colorHex: '#96CEB4',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '5',
      name: 'Loisirs',
      icon: 'sports_esports',
      colorHex: '#FFEAA7',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '6',
      name: 'Shopping',
      icon: 'shopping_cart',
      colorHex: '#DFE6E9',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '7',
      name: 'Éducation',
      icon: 'school',
      colorHex: '#74B9FF',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '8',
      name: 'Sport',
      icon: 'fitness_center',
      colorHex: '#A29BFE',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '9',
      name: 'Téléphone',
      icon: 'phone',
      colorHex: '#FD79A8',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '10',
      name: 'Carburant',
      icon: 'local_gas_station',
      colorHex: '#FDCB6E',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '11',
      name: 'Beauté',
      icon: 'face',
      colorHex: '#FF85C0',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '12',
      name: 'Couture',
      icon: 'content_cut',
      colorHex: '#9B59B6',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '13',
      name: 'Café & Restaurant',
      icon: 'restaurant_menu',
      colorHex: '#E17055',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '14',
      name: 'Café',
      icon: 'coffee',
      colorHex: '#6C5CE7',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '15',
      name: 'Cinéma',
      icon: 'movie',
      colorHex: '#0984E3',
      type: TransactionType.expense,
      isDefault: true,
    ),
    const CategoryModel(
      id: '16',
      name: 'Animaux',
      icon: 'pets',
      colorHex: '#FDCB6E',
      type: TransactionType.expense,
      isDefault: true,
    ),
  ];

  static final List<CategoryModel> income = [
    const CategoryModel(
      id: '21',
      name: 'Salaire',
      icon: 'account_balance_wallet',
      colorHex: '#55EFC4',
      type: TransactionType.income,
      isDefault: true,
    ),
    const CategoryModel(
      id: '22',
      name: 'Freelance',
      icon: 'work',
      colorHex: '#74B9FF',
      type: TransactionType.income,
      isDefault: true,
    ),
    const CategoryModel(
      id: '23',
      name: 'Business',
      icon: 'business',
      colorHex: '#A29BFE',
      type: TransactionType.income,
      isDefault: true,
    ),
    const CategoryModel(
      id: '24',
      name: 'Investissement',
      icon: 'trending_up',
      colorHex: '#00B894',
      type: TransactionType.income,
      isDefault: true,
    ),
    const CategoryModel(
      id: '25',
      name: 'Cadeau',
      icon: 'card_giftcard',
      colorHex: '#FD79A8',
      type: TransactionType.income,
      isDefault: true,
    ),
    const CategoryModel(
      id: '26',
      name: 'Autre',
      icon: 'attach_money',
      colorHex: '#6C5CE7',
      type: TransactionType.income,
      isDefault: true,
    ),
  ];

  static List<CategoryModel> get all => [...expenses, ...income];
}