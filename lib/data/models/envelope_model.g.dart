// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envelope_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EnvelopeModelImpl _$$EnvelopeModelImplFromJson(Map<String, dynamic> json) =>
    _$EnvelopeModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      colorHex: json['colorHex'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      autoRefill: json['autoRefill'] as bool? ?? false,
      rollover: json['rollover'] as bool? ?? false,
      categoryId: json['categoryId'] as String?,
      lastRefillDate: json['lastRefillDate'] == null
          ? null
          : DateTime.parse(json['lastRefillDate'] as String),
    );

Map<String, dynamic> _$$EnvelopeModelImplToJson(_$EnvelopeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'colorHex': instance.colorHex,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'spentAmount': instance.spentAmount,
      'autoRefill': instance.autoRefill,
      'rollover': instance.rollover,
      'categoryId': instance.categoryId,
      'lastRefillDate': instance.lastRefillDate?.toIso8601String(),
    };
