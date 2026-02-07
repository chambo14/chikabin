// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'envelope_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EnvelopeModel _$EnvelopeModelFromJson(Map<String, dynamic> json) {
  return _EnvelopeModel.fromJson(json);
}

/// @nodoc
mixin _$EnvelopeModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;
  double get targetAmount =>
      throw _privateConstructorUsedError; // Montant cible mensuel
  double get currentAmount =>
      throw _privateConstructorUsedError; // Montant actuel dans l'enveloppe
  double get spentAmount =>
      throw _privateConstructorUsedError; // Montant dépensé ce mois
  bool get autoRefill =>
      throw _privateConstructorUsedError; // Remplissage auto chaque mois
  bool get rollover =>
      throw _privateConstructorUsedError; // Reporter le reste sur mois suivant
  String? get categoryId =>
      throw _privateConstructorUsedError; // Lien optionnel avec une catégorie
  DateTime? get lastRefillDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EnvelopeModelCopyWith<EnvelopeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnvelopeModelCopyWith<$Res> {
  factory $EnvelopeModelCopyWith(
          EnvelopeModel value, $Res Function(EnvelopeModel) then) =
      _$EnvelopeModelCopyWithImpl<$Res, EnvelopeModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      String colorHex,
      double targetAmount,
      double currentAmount,
      double spentAmount,
      bool autoRefill,
      bool rollover,
      String? categoryId,
      DateTime? lastRefillDate});
}

/// @nodoc
class _$EnvelopeModelCopyWithImpl<$Res, $Val extends EnvelopeModel>
    implements $EnvelopeModelCopyWith<$Res> {
  _$EnvelopeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? colorHex = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? spentAmount = null,
    Object? autoRefill = null,
    Object? rollover = null,
    Object? categoryId = freezed,
    Object? lastRefillDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      colorHex: null == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currentAmount: null == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      spentAmount: null == spentAmount
          ? _value.spentAmount
          : spentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      autoRefill: null == autoRefill
          ? _value.autoRefill
          : autoRefill // ignore: cast_nullable_to_non_nullable
              as bool,
      rollover: null == rollover
          ? _value.rollover
          : rollover // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastRefillDate: freezed == lastRefillDate
          ? _value.lastRefillDate
          : lastRefillDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EnvelopeModelImplCopyWith<$Res>
    implements $EnvelopeModelCopyWith<$Res> {
  factory _$$EnvelopeModelImplCopyWith(
          _$EnvelopeModelImpl value, $Res Function(_$EnvelopeModelImpl) then) =
      __$$EnvelopeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      String colorHex,
      double targetAmount,
      double currentAmount,
      double spentAmount,
      bool autoRefill,
      bool rollover,
      String? categoryId,
      DateTime? lastRefillDate});
}

/// @nodoc
class __$$EnvelopeModelImplCopyWithImpl<$Res>
    extends _$EnvelopeModelCopyWithImpl<$Res, _$EnvelopeModelImpl>
    implements _$$EnvelopeModelImplCopyWith<$Res> {
  __$$EnvelopeModelImplCopyWithImpl(
      _$EnvelopeModelImpl _value, $Res Function(_$EnvelopeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? colorHex = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? spentAmount = null,
    Object? autoRefill = null,
    Object? rollover = null,
    Object? categoryId = freezed,
    Object? lastRefillDate = freezed,
  }) {
    return _then(_$EnvelopeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      colorHex: null == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currentAmount: null == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      spentAmount: null == spentAmount
          ? _value.spentAmount
          : spentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      autoRefill: null == autoRefill
          ? _value.autoRefill
          : autoRefill // ignore: cast_nullable_to_non_nullable
              as bool,
      rollover: null == rollover
          ? _value.rollover
          : rollover // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastRefillDate: freezed == lastRefillDate
          ? _value.lastRefillDate
          : lastRefillDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EnvelopeModelImpl extends _EnvelopeModel {
  const _$EnvelopeModelImpl(
      {required this.id,
      required this.name,
      required this.icon,
      required this.colorHex,
      required this.targetAmount,
      required this.currentAmount,
      required this.spentAmount,
      this.autoRefill = false,
      this.rollover = false,
      this.categoryId,
      this.lastRefillDate})
      : super._();

  factory _$EnvelopeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnvelopeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  @override
  final String colorHex;
  @override
  final double targetAmount;
// Montant cible mensuel
  @override
  final double currentAmount;
// Montant actuel dans l'enveloppe
  @override
  final double spentAmount;
// Montant dépensé ce mois
  @override
  @JsonKey()
  final bool autoRefill;
// Remplissage auto chaque mois
  @override
  @JsonKey()
  final bool rollover;
// Reporter le reste sur mois suivant
  @override
  final String? categoryId;
// Lien optionnel avec une catégorie
  @override
  final DateTime? lastRefillDate;

  @override
  String toString() {
    return 'EnvelopeModel(id: $id, name: $name, icon: $icon, colorHex: $colorHex, targetAmount: $targetAmount, currentAmount: $currentAmount, spentAmount: $spentAmount, autoRefill: $autoRefill, rollover: $rollover, categoryId: $categoryId, lastRefillDate: $lastRefillDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnvelopeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.spentAmount, spentAmount) ||
                other.spentAmount == spentAmount) &&
            (identical(other.autoRefill, autoRefill) ||
                other.autoRefill == autoRefill) &&
            (identical(other.rollover, rollover) ||
                other.rollover == rollover) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.lastRefillDate, lastRefillDate) ||
                other.lastRefillDate == lastRefillDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      icon,
      colorHex,
      targetAmount,
      currentAmount,
      spentAmount,
      autoRefill,
      rollover,
      categoryId,
      lastRefillDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EnvelopeModelImplCopyWith<_$EnvelopeModelImpl> get copyWith =>
      __$$EnvelopeModelImplCopyWithImpl<_$EnvelopeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnvelopeModelImplToJson(
      this,
    );
  }
}

abstract class _EnvelopeModel extends EnvelopeModel {
  const factory _EnvelopeModel(
      {required final String id,
      required final String name,
      required final String icon,
      required final String colorHex,
      required final double targetAmount,
      required final double currentAmount,
      required final double spentAmount,
      final bool autoRefill,
      final bool rollover,
      final String? categoryId,
      final DateTime? lastRefillDate}) = _$EnvelopeModelImpl;
  const _EnvelopeModel._() : super._();

  factory _EnvelopeModel.fromJson(Map<String, dynamic> json) =
      _$EnvelopeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  String get colorHex;
  @override
  double get targetAmount;
  @override // Montant cible mensuel
  double get currentAmount;
  @override // Montant actuel dans l'enveloppe
  double get spentAmount;
  @override // Montant dépensé ce mois
  bool get autoRefill;
  @override // Remplissage auto chaque mois
  bool get rollover;
  @override // Reporter le reste sur mois suivant
  String? get categoryId;
  @override // Lien optionnel avec une catégorie
  DateTime? get lastRefillDate;
  @override
  @JsonKey(ignore: true)
  _$$EnvelopeModelImplCopyWith<_$EnvelopeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
