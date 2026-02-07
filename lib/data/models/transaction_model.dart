import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

// Enum pour le type de transaction
enum TransactionType {
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense,
}

// Extension pour obtenir des informations sur le type
extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Revenu';
      case TransactionType.expense:
        return 'Dépense';
    }
  }

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;
}

@freezed
class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required String id,
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? envelopeId,
    String? description,
    String? receipt, // chemin de l'image du reçu
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  // Méthodes utilitaires
  String get formattedAmount {
    final sign = type == TransactionType.income ? '+' : '-';
    return '$sign ${amount.toStringAsFixed(0)} FCFA';
  }

  bool get hasReceipt => receipt != null && receipt!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
}