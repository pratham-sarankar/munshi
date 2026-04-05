// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionCategory {

 int get id; String get name; IconData get icon; Color get color; TransactionType get type; bool get isDefault; DateTime get createdAt;
/// Create a copy of TransactionCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCategoryCopyWith<TransactionCategory> get copyWith => _$TransactionCategoryCopyWithImpl<TransactionCategory>(this as TransactionCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,icon,color,type,isDefault,createdAt);

@override
String toString() {
  return 'TransactionCategory(id: $id, name: $name, icon: $icon, color: $color, type: $type, isDefault: $isDefault, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TransactionCategoryCopyWith<$Res>  {
  factory $TransactionCategoryCopyWith(TransactionCategory value, $Res Function(TransactionCategory) _then) = _$TransactionCategoryCopyWithImpl;
@useResult
$Res call({
 int id, String name, IconData icon, Color color, TransactionType type, bool isDefault, DateTime createdAt
});




}
/// @nodoc
class _$TransactionCategoryCopyWithImpl<$Res>
    implements $TransactionCategoryCopyWith<$Res> {
  _$TransactionCategoryCopyWithImpl(this._self, this._then);

  final TransactionCategory _self;
  final $Res Function(TransactionCategory) _then;

/// Create a copy of TransactionCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,Object? type = null,Object? isDefault = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionCategory].
extension TransactionCategoryPatterns on TransactionCategory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionCategory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionCategory value)  $default,){
final _that = this;
switch (_that) {
case _TransactionCategory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionCategory value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionCategory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  IconData icon,  Color color,  TransactionType type,  bool isDefault,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionCategory() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color,_that.type,_that.isDefault,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  IconData icon,  Color color,  TransactionType type,  bool isDefault,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TransactionCategory():
return $default(_that.id,_that.name,_that.icon,_that.color,_that.type,_that.isDefault,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  IconData icon,  Color color,  TransactionType type,  bool isDefault,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TransactionCategory() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color,_that.type,_that.isDefault,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionCategory implements TransactionCategory {
  const _TransactionCategory({required this.id, required this.name, required this.icon, required this.color, required this.type, required this.isDefault, required this.createdAt});
  

@override final  int id;
@override final  String name;
@override final  IconData icon;
@override final  Color color;
@override final  TransactionType type;
@override final  bool isDefault;
@override final  DateTime createdAt;

/// Create a copy of TransactionCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCategoryCopyWith<_TransactionCategory> get copyWith => __$TransactionCategoryCopyWithImpl<_TransactionCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,icon,color,type,isDefault,createdAt);

@override
String toString() {
  return 'TransactionCategory(id: $id, name: $name, icon: $icon, color: $color, type: $type, isDefault: $isDefault, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionCategoryCopyWith<$Res> implements $TransactionCategoryCopyWith<$Res> {
  factory _$TransactionCategoryCopyWith(_TransactionCategory value, $Res Function(_TransactionCategory) _then) = __$TransactionCategoryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, IconData icon, Color color, TransactionType type, bool isDefault, DateTime createdAt
});




}
/// @nodoc
class __$TransactionCategoryCopyWithImpl<$Res>
    implements _$TransactionCategoryCopyWith<$Res> {
  __$TransactionCategoryCopyWithImpl(this._self, this._then);

  final _TransactionCategory _self;
  final $Res Function(_TransactionCategory) _then;

/// Create a copy of TransactionCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,Object? type = null,Object? isDefault = null,Object? createdAt = null,}) {
  return _then(_TransactionCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
