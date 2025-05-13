// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rsvp_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RSVPModel {

 String get uid; String get response; DateTime get timestamp; bool get paid;
/// Create a copy of RSVPModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RSVPModelCopyWith<RSVPModel> get copyWith => _$RSVPModelCopyWithImpl<RSVPModel>(this as RSVPModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RSVPModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.response, response) || other.response == response)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.paid, paid) || other.paid == paid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,response,timestamp,paid);

@override
String toString() {
  return 'RSVPModel(uid: $uid, response: $response, timestamp: $timestamp, paid: $paid)';
}


}

/// @nodoc
abstract mixin class $RSVPModelCopyWith<$Res>  {
  factory $RSVPModelCopyWith(RSVPModel value, $Res Function(RSVPModel) _then) = _$RSVPModelCopyWithImpl;
@useResult
$Res call({
 String uid, String response, DateTime timestamp, bool paid
});




}
/// @nodoc
class _$RSVPModelCopyWithImpl<$Res>
    implements $RSVPModelCopyWith<$Res> {
  _$RSVPModelCopyWithImpl(this._self, this._then);

  final RSVPModel _self;
  final $Res Function(RSVPModel) _then;

/// Create a copy of RSVPModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? response = null,Object? timestamp = null,Object? paid = null,}) {
  return _then(RSVPModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


// dart format on
