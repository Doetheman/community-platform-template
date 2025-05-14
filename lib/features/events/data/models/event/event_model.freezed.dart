// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventModel {

 String? get id;// Document ID (not stored in Firestore)
 String? get title; DateTime? get dateTime; String? get location; String? get description; bool? get isPaid; double? get price; String? get hostId; int? get capacity; String? get imageUrl; List<String>? get galleryImageUrls; String? get category; Map<String, dynamic>? get additionalInfo;
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelCopyWith<EventModel> get copyWith => _$EventModelCopyWithImpl<EventModel>(this as EventModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.price, price) || other.price == price)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.galleryImageUrls, galleryImageUrls)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.additionalInfo, additionalInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,dateTime,location,description,isPaid,price,hostId,capacity,imageUrl,const DeepCollectionEquality().hash(galleryImageUrls),category,const DeepCollectionEquality().hash(additionalInfo));

@override
String toString() {
  return 'EventModel(id: $id, title: $title, dateTime: $dateTime, location: $location, description: $description, isPaid: $isPaid, price: $price, hostId: $hostId, capacity: $capacity, imageUrl: $imageUrl, galleryImageUrls: $galleryImageUrls, category: $category, additionalInfo: $additionalInfo)';
}


}

/// @nodoc
abstract mixin class $EventModelCopyWith<$Res>  {
  factory $EventModelCopyWith(EventModel value, $Res Function(EventModel) _then) = _$EventModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? title, DateTime? dateTime, String? location, String? description, bool? isPaid, double? price, String? hostId, int? capacity, String? imageUrl, List<String>? galleryImageUrls, String? category, Map<String, dynamic>? additionalInfo
});




}
/// @nodoc
class _$EventModelCopyWithImpl<$Res>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._self, this._then);

  final EventModel _self;
  final $Res Function(EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = freezed,Object? dateTime = freezed,Object? location = freezed,Object? description = freezed,Object? isPaid = freezed,Object? price = freezed,Object? hostId = freezed,Object? capacity = freezed,Object? imageUrl = freezed,Object? galleryImageUrls = freezed,Object? category = freezed,Object? additionalInfo = freezed,}) {
  return _then(EventModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,dateTime: freezed == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPaid: freezed == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,hostId: freezed == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String?,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,galleryImageUrls: freezed == galleryImageUrls ? _self.galleryImageUrls : galleryImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,additionalInfo: freezed == additionalInfo ? _self.additionalInfo : additionalInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


// dart format on
