// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryModelImpl _$$CategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$CategoryModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      colorHex: json['colorHex'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$CategoryModelImplToJson(_$CategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'colorHex': instance.colorHex,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'isDefault': instance.isDefault,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};
