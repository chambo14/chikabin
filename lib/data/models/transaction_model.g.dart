// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      envelopeId: json['envelopeId'] as String?,
      description: json['description'] as String?,
      receipt: json['receipt'] as String?,
    );

Map<String, dynamic> _$$TransactionModelImplToJson(
        _$TransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'categoryId': instance.categoryId,
      'date': instance.date.toIso8601String(),
      'envelopeId': instance.envelopeId,
      'description': instance.description,
      'receipt': instance.receipt,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};
