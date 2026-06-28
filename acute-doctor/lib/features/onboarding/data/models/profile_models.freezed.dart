// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Education {
  String get id;
  String get degree;
  @JsonKey(name: 'registration_number')
  String get registrationNumber;
  String? get institution;
  @JsonKey(name: 'year_of_completion')
  int? get yearOfCompletion;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EducationCopyWith<Education> get copyWith =>
      _$EducationCopyWithImpl<Education>(this as Education, _$identity);

  /// Serializes this Education to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Education &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.degree, degree) || other.degree == degree) &&
            (identical(other.registrationNumber, registrationNumber) ||
                other.registrationNumber == registrationNumber) &&
            (identical(other.institution, institution) ||
                other.institution == institution) &&
            (identical(other.yearOfCompletion, yearOfCompletion) ||
                other.yearOfCompletion == yearOfCompletion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, degree, registrationNumber,
      institution, yearOfCompletion);

  @override
  String toString() {
    return 'Education(id: $id, degree: $degree, registrationNumber: $registrationNumber, institution: $institution, yearOfCompletion: $yearOfCompletion)';
  }
}

/// @nodoc
abstract mixin class $EducationCopyWith<$Res> {
  factory $EducationCopyWith(Education value, $Res Function(Education) _then) =
      _$EducationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String degree,
      @JsonKey(name: 'registration_number') String registrationNumber,
      String? institution,
      @JsonKey(name: 'year_of_completion') int? yearOfCompletion});
}

/// @nodoc
class _$EducationCopyWithImpl<$Res> implements $EducationCopyWith<$Res> {
  _$EducationCopyWithImpl(this._self, this._then);

  final Education _self;
  final $Res Function(Education) _then;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? degree = null,
    Object? registrationNumber = null,
    Object? institution = freezed,
    Object? yearOfCompletion = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      degree: null == degree
          ? _self.degree
          : degree // ignore: cast_nullable_to_non_nullable
              as String,
      registrationNumber: null == registrationNumber
          ? _self.registrationNumber
          : registrationNumber // ignore: cast_nullable_to_non_nullable
              as String,
      institution: freezed == institution
          ? _self.institution
          : institution // ignore: cast_nullable_to_non_nullable
              as String?,
      yearOfCompletion: freezed == yearOfCompletion
          ? _self.yearOfCompletion
          : yearOfCompletion // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Education].
extension EducationPatterns on Education {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Education value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Education() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Education value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Education():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Education value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Education() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String degree,
            @JsonKey(name: 'registration_number') String registrationNumber,
            String? institution,
            @JsonKey(name: 'year_of_completion') int? yearOfCompletion)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Education() when $default != null:
        return $default(_that.id, _that.degree, _that.registrationNumber,
            _that.institution, _that.yearOfCompletion);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String degree,
            @JsonKey(name: 'registration_number') String registrationNumber,
            String? institution,
            @JsonKey(name: 'year_of_completion') int? yearOfCompletion)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Education():
        return $default(_that.id, _that.degree, _that.registrationNumber,
            _that.institution, _that.yearOfCompletion);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String degree,
            @JsonKey(name: 'registration_number') String registrationNumber,
            String? institution,
            @JsonKey(name: 'year_of_completion') int? yearOfCompletion)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Education() when $default != null:
        return $default(_that.id, _that.degree, _that.registrationNumber,
            _that.institution, _that.yearOfCompletion);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Education implements Education {
  const _Education(
      {required this.id,
      required this.degree,
      @JsonKey(name: 'registration_number') required this.registrationNumber,
      this.institution,
      @JsonKey(name: 'year_of_completion') this.yearOfCompletion});
  factory _Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);

  @override
  final String id;
  @override
  final String degree;
  @override
  @JsonKey(name: 'registration_number')
  final String registrationNumber;
  @override
  final String? institution;
  @override
  @JsonKey(name: 'year_of_completion')
  final int? yearOfCompletion;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EducationCopyWith<_Education> get copyWith =>
      __$EducationCopyWithImpl<_Education>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EducationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Education &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.degree, degree) || other.degree == degree) &&
            (identical(other.registrationNumber, registrationNumber) ||
                other.registrationNumber == registrationNumber) &&
            (identical(other.institution, institution) ||
                other.institution == institution) &&
            (identical(other.yearOfCompletion, yearOfCompletion) ||
                other.yearOfCompletion == yearOfCompletion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, degree, registrationNumber,
      institution, yearOfCompletion);

  @override
  String toString() {
    return 'Education(id: $id, degree: $degree, registrationNumber: $registrationNumber, institution: $institution, yearOfCompletion: $yearOfCompletion)';
  }
}

/// @nodoc
abstract mixin class _$EducationCopyWith<$Res>
    implements $EducationCopyWith<$Res> {
  factory _$EducationCopyWith(
          _Education value, $Res Function(_Education) _then) =
      __$EducationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String degree,
      @JsonKey(name: 'registration_number') String registrationNumber,
      String? institution,
      @JsonKey(name: 'year_of_completion') int? yearOfCompletion});
}

/// @nodoc
class __$EducationCopyWithImpl<$Res> implements _$EducationCopyWith<$Res> {
  __$EducationCopyWithImpl(this._self, this._then);

  final _Education _self;
  final $Res Function(_Education) _then;

  /// Create a copy of Education
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? degree = null,
    Object? registrationNumber = null,
    Object? institution = freezed,
    Object? yearOfCompletion = freezed,
  }) {
    return _then(_Education(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      degree: null == degree
          ? _self.degree
          : degree // ignore: cast_nullable_to_non_nullable
              as String,
      registrationNumber: null == registrationNumber
          ? _self.registrationNumber
          : registrationNumber // ignore: cast_nullable_to_non_nullable
              as String,
      institution: freezed == institution
          ? _self.institution
          : institution // ignore: cast_nullable_to_non_nullable
              as String?,
      yearOfCompletion: freezed == yearOfCompletion
          ? _self.yearOfCompletion
          : yearOfCompletion // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$Speciality {
  String get id;
  String get name;

  /// Create a copy of Speciality
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SpecialityCopyWith<Speciality> get copyWith =>
      _$SpecialityCopyWithImpl<Speciality>(this as Speciality, _$identity);

  /// Serializes this Speciality to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Speciality &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @override
  String toString() {
    return 'Speciality(id: $id, name: $name)';
  }
}

/// @nodoc
abstract mixin class $SpecialityCopyWith<$Res> {
  factory $SpecialityCopyWith(
          Speciality value, $Res Function(Speciality) _then) =
      _$SpecialityCopyWithImpl;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$SpecialityCopyWithImpl<$Res> implements $SpecialityCopyWith<$Res> {
  _$SpecialityCopyWithImpl(this._self, this._then);

  final Speciality _self;
  final $Res Function(Speciality) _then;

  /// Create a copy of Speciality
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Speciality].
extension SpecialityPatterns on Speciality {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Speciality value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Speciality() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Speciality value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Speciality():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Speciality value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Speciality() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String name)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Speciality() when $default != null:
        return $default(_that.id, _that.name);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String name) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Speciality():
        return $default(_that.id, _that.name);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String name)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Speciality() when $default != null:
        return $default(_that.id, _that.name);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Speciality implements Speciality {
  const _Speciality({required this.id, required this.name});
  factory _Speciality.fromJson(Map<String, dynamic> json) =>
      _$SpecialityFromJson(json);

  @override
  final String id;
  @override
  final String name;

  /// Create a copy of Speciality
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SpecialityCopyWith<_Speciality> get copyWith =>
      __$SpecialityCopyWithImpl<_Speciality>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SpecialityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Speciality &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @override
  String toString() {
    return 'Speciality(id: $id, name: $name)';
  }
}

/// @nodoc
abstract mixin class _$SpecialityCopyWith<$Res>
    implements $SpecialityCopyWith<$Res> {
  factory _$SpecialityCopyWith(
          _Speciality value, $Res Function(_Speciality) _then) =
      __$SpecialityCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$SpecialityCopyWithImpl<$Res> implements _$SpecialityCopyWith<$Res> {
  __$SpecialityCopyWithImpl(this._self, this._then);

  final _Speciality _self;
  final $Res Function(_Speciality) _then;

  /// Create a copy of Speciality
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_Speciality(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Hospital {
  String get id;
  String get name;
  String get type;
  String? get city;
  String? get address;

  /// Create a copy of Hospital
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HospitalCopyWith<Hospital> get copyWith =>
      _$HospitalCopyWithImpl<Hospital>(this as Hospital, _$identity);

  /// Serializes this Hospital to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Hospital &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, city, address);

  @override
  String toString() {
    return 'Hospital(id: $id, name: $name, type: $type, city: $city, address: $address)';
  }
}

/// @nodoc
abstract mixin class $HospitalCopyWith<$Res> {
  factory $HospitalCopyWith(Hospital value, $Res Function(Hospital) _then) =
      _$HospitalCopyWithImpl;
  @useResult
  $Res call(
      {String id, String name, String type, String? city, String? address});
}

/// @nodoc
class _$HospitalCopyWithImpl<$Res> implements $HospitalCopyWith<$Res> {
  _$HospitalCopyWithImpl(this._self, this._then);

  final Hospital _self;
  final $Res Function(Hospital) _then;

  /// Create a copy of Hospital
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? city = freezed,
    Object? address = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Hospital].
extension HospitalPatterns on Hospital {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Hospital value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Hospital() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Hospital value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Hospital():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Hospital value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Hospital() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id, String name, String type, String? city, String? address)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Hospital() when $default != null:
        return $default(
            _that.id, _that.name, _that.type, _that.city, _that.address);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id, String name, String type, String? city, String? address)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Hospital():
        return $default(
            _that.id, _that.name, _that.type, _that.city, _that.address);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id, String name, String type, String? city, String? address)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Hospital() when $default != null:
        return $default(
            _that.id, _that.name, _that.type, _that.city, _that.address);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Hospital implements Hospital {
  const _Hospital(
      {required this.id,
      required this.name,
      required this.type,
      this.city,
      this.address});
  factory _Hospital.fromJson(Map<String, dynamic> json) =>
      _$HospitalFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String? city;
  @override
  final String? address;

  /// Create a copy of Hospital
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HospitalCopyWith<_Hospital> get copyWith =>
      __$HospitalCopyWithImpl<_Hospital>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HospitalToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Hospital &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, city, address);

  @override
  String toString() {
    return 'Hospital(id: $id, name: $name, type: $type, city: $city, address: $address)';
  }
}

/// @nodoc
abstract mixin class _$HospitalCopyWith<$Res>
    implements $HospitalCopyWith<$Res> {
  factory _$HospitalCopyWith(_Hospital value, $Res Function(_Hospital) _then) =
      __$HospitalCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id, String name, String type, String? city, String? address});
}

/// @nodoc
class __$HospitalCopyWithImpl<$Res> implements _$HospitalCopyWith<$Res> {
  __$HospitalCopyWithImpl(this._self, this._then);

  final _Hospital _self;
  final $Res Function(_Hospital) _then;

  /// Create a copy of Hospital
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? city = freezed,
    Object? address = freezed,
  }) {
    return _then(_Hospital(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$WorkingHour {
  String get id;
  @JsonKey(name: 'day_of_week')
  int get dayOfWeek;
  @JsonKey(name: 'start_time')
  String get startTime;
  @JsonKey(name: 'end_time')
  String get endTime;

  /// Create a copy of WorkingHour
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WorkingHourCopyWith<WorkingHour> get copyWith =>
      _$WorkingHourCopyWithImpl<WorkingHour>(this as WorkingHour, _$identity);

  /// Serializes this WorkingHour to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WorkingHour &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, dayOfWeek, startTime, endTime);

  @override
  String toString() {
    return 'WorkingHour(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
  }
}

/// @nodoc
abstract mixin class $WorkingHourCopyWith<$Res> {
  factory $WorkingHourCopyWith(
          WorkingHour value, $Res Function(WorkingHour) _then) =
      _$WorkingHourCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'day_of_week') int dayOfWeek,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime});
}

/// @nodoc
class _$WorkingHourCopyWithImpl<$Res> implements $WorkingHourCopyWith<$Res> {
  _$WorkingHourCopyWithImpl(this._self, this._then);

  final WorkingHour _self;
  final $Res Function(WorkingHour) _then;

  /// Create a copy of WorkingHour
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _self.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [WorkingHour].
extension WorkingHourPatterns on WorkingHour {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WorkingHour value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkingHour() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WorkingHour value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkingHour():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WorkingHour value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkingHour() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            @JsonKey(name: 'day_of_week') int dayOfWeek,
            @JsonKey(name: 'start_time') String startTime,
            @JsonKey(name: 'end_time') String endTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkingHour() when $default != null:
        return $default(
            _that.id, _that.dayOfWeek, _that.startTime, _that.endTime);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            @JsonKey(name: 'day_of_week') int dayOfWeek,
            @JsonKey(name: 'start_time') String startTime,
            @JsonKey(name: 'end_time') String endTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkingHour():
        return $default(
            _that.id, _that.dayOfWeek, _that.startTime, _that.endTime);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            @JsonKey(name: 'day_of_week') int dayOfWeek,
            @JsonKey(name: 'start_time') String startTime,
            @JsonKey(name: 'end_time') String endTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkingHour() when $default != null:
        return $default(
            _that.id, _that.dayOfWeek, _that.startTime, _that.endTime);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WorkingHour implements WorkingHour {
  const _WorkingHour(
      {required this.id,
      @JsonKey(name: 'day_of_week') required this.dayOfWeek,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') required this.endTime});
  factory _WorkingHour.fromJson(Map<String, dynamic> json) =>
      _$WorkingHourFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;
  @override
  @JsonKey(name: 'start_time')
  final String startTime;
  @override
  @JsonKey(name: 'end_time')
  final String endTime;

  /// Create a copy of WorkingHour
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WorkingHourCopyWith<_WorkingHour> get copyWith =>
      __$WorkingHourCopyWithImpl<_WorkingHour>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WorkingHourToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WorkingHour &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, dayOfWeek, startTime, endTime);

  @override
  String toString() {
    return 'WorkingHour(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
  }
}

/// @nodoc
abstract mixin class _$WorkingHourCopyWith<$Res>
    implements $WorkingHourCopyWith<$Res> {
  factory _$WorkingHourCopyWith(
          _WorkingHour value, $Res Function(_WorkingHour) _then) =
      __$WorkingHourCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'day_of_week') int dayOfWeek,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime});
}

/// @nodoc
class __$WorkingHourCopyWithImpl<$Res> implements _$WorkingHourCopyWith<$Res> {
  __$WorkingHourCopyWithImpl(this._self, this._then);

  final _WorkingHour _self;
  final $Res Function(_WorkingHour) _then;

  /// Create a copy of WorkingHour
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_WorkingHour(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _self.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Experience {
  String get id;
  Hospital get hospital;
  String? get designation;
  @JsonKey(name: 'start_date')
  String? get startDate;
  @JsonKey(name: 'end_date')
  String? get endDate;
  @JsonKey(name: 'is_current')
  bool get isCurrent;
  @JsonKey(name: 'working_hours')
  List<WorkingHour> get workingHours;

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExperienceCopyWith<Experience> get copyWith =>
      _$ExperienceCopyWithImpl<Experience>(this as Experience, _$identity);

  /// Serializes this Experience to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Experience &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.hospital, hospital) ||
                other.hospital == hospital) &&
            (identical(other.designation, designation) ||
                other.designation == designation) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent) &&
            const DeepCollectionEquality()
                .equals(other.workingHours, workingHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      hospital,
      designation,
      startDate,
      endDate,
      isCurrent,
      const DeepCollectionEquality().hash(workingHours));

  @override
  String toString() {
    return 'Experience(id: $id, hospital: $hospital, designation: $designation, startDate: $startDate, endDate: $endDate, isCurrent: $isCurrent, workingHours: $workingHours)';
  }
}

/// @nodoc
abstract mixin class $ExperienceCopyWith<$Res> {
  factory $ExperienceCopyWith(
          Experience value, $Res Function(Experience) _then) =
      _$ExperienceCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      Hospital hospital,
      String? designation,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      @JsonKey(name: 'is_current') bool isCurrent,
      @JsonKey(name: 'working_hours') List<WorkingHour> workingHours});

  $HospitalCopyWith<$Res> get hospital;
}

/// @nodoc
class _$ExperienceCopyWithImpl<$Res> implements $ExperienceCopyWith<$Res> {
  _$ExperienceCopyWithImpl(this._self, this._then);

  final Experience _self;
  final $Res Function(Experience) _then;

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hospital = null,
    Object? designation = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? isCurrent = null,
    Object? workingHours = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      hospital: null == hospital
          ? _self.hospital
          : hospital // ignore: cast_nullable_to_non_nullable
              as Hospital,
      designation: freezed == designation
          ? _self.designation
          : designation // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      isCurrent: null == isCurrent
          ? _self.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      workingHours: null == workingHours
          ? _self.workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as List<WorkingHour>,
    ));
  }

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HospitalCopyWith<$Res> get hospital {
    return $HospitalCopyWith<$Res>(_self.hospital, (value) {
      return _then(_self.copyWith(hospital: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Experience].
extension ExperiencePatterns on Experience {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Experience value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Experience() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Experience value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Experience():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Experience value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Experience() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            Hospital hospital,
            String? designation,
            @JsonKey(name: 'start_date') String? startDate,
            @JsonKey(name: 'end_date') String? endDate,
            @JsonKey(name: 'is_current') bool isCurrent,
            @JsonKey(name: 'working_hours') List<WorkingHour> workingHours)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Experience() when $default != null:
        return $default(
            _that.id,
            _that.hospital,
            _that.designation,
            _that.startDate,
            _that.endDate,
            _that.isCurrent,
            _that.workingHours);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            Hospital hospital,
            String? designation,
            @JsonKey(name: 'start_date') String? startDate,
            @JsonKey(name: 'end_date') String? endDate,
            @JsonKey(name: 'is_current') bool isCurrent,
            @JsonKey(name: 'working_hours') List<WorkingHour> workingHours)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Experience():
        return $default(
            _that.id,
            _that.hospital,
            _that.designation,
            _that.startDate,
            _that.endDate,
            _that.isCurrent,
            _that.workingHours);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            Hospital hospital,
            String? designation,
            @JsonKey(name: 'start_date') String? startDate,
            @JsonKey(name: 'end_date') String? endDate,
            @JsonKey(name: 'is_current') bool isCurrent,
            @JsonKey(name: 'working_hours') List<WorkingHour> workingHours)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Experience() when $default != null:
        return $default(
            _that.id,
            _that.hospital,
            _that.designation,
            _that.startDate,
            _that.endDate,
            _that.isCurrent,
            _that.workingHours);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Experience implements Experience {
  const _Experience(
      {required this.id,
      required this.hospital,
      this.designation,
      @JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      @JsonKey(name: 'is_current') this.isCurrent = false,
      @JsonKey(name: 'working_hours')
      final List<WorkingHour> workingHours = const []})
      : _workingHours = workingHours;
  factory _Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  @override
  final String id;
  @override
  final Hospital hospital;
  @override
  final String? designation;
  @override
  @JsonKey(name: 'start_date')
  final String? startDate;
  @override
  @JsonKey(name: 'end_date')
  final String? endDate;
  @override
  @JsonKey(name: 'is_current')
  final bool isCurrent;
  final List<WorkingHour> _workingHours;
  @override
  @JsonKey(name: 'working_hours')
  List<WorkingHour> get workingHours {
    if (_workingHours is EqualUnmodifiableListView) return _workingHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workingHours);
  }

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExperienceCopyWith<_Experience> get copyWith =>
      __$ExperienceCopyWithImpl<_Experience>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExperienceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Experience &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.hospital, hospital) ||
                other.hospital == hospital) &&
            (identical(other.designation, designation) ||
                other.designation == designation) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent) &&
            const DeepCollectionEquality()
                .equals(other._workingHours, _workingHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      hospital,
      designation,
      startDate,
      endDate,
      isCurrent,
      const DeepCollectionEquality().hash(_workingHours));

  @override
  String toString() {
    return 'Experience(id: $id, hospital: $hospital, designation: $designation, startDate: $startDate, endDate: $endDate, isCurrent: $isCurrent, workingHours: $workingHours)';
  }
}

/// @nodoc
abstract mixin class _$ExperienceCopyWith<$Res>
    implements $ExperienceCopyWith<$Res> {
  factory _$ExperienceCopyWith(
          _Experience value, $Res Function(_Experience) _then) =
      __$ExperienceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      Hospital hospital,
      String? designation,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      @JsonKey(name: 'is_current') bool isCurrent,
      @JsonKey(name: 'working_hours') List<WorkingHour> workingHours});

  @override
  $HospitalCopyWith<$Res> get hospital;
}

/// @nodoc
class __$ExperienceCopyWithImpl<$Res> implements _$ExperienceCopyWith<$Res> {
  __$ExperienceCopyWithImpl(this._self, this._then);

  final _Experience _self;
  final $Res Function(_Experience) _then;

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? hospital = null,
    Object? designation = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? isCurrent = null,
    Object? workingHours = null,
  }) {
    return _then(_Experience(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      hospital: null == hospital
          ? _self.hospital
          : hospital // ignore: cast_nullable_to_non_nullable
              as Hospital,
      designation: freezed == designation
          ? _self.designation
          : designation // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      isCurrent: null == isCurrent
          ? _self.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      workingHours: null == workingHours
          ? _self._workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as List<WorkingHour>,
    ));
  }

  /// Create a copy of Experience
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HospitalCopyWith<$Res> get hospital {
    return $HospitalCopyWith<$Res>(_self.hospital, (value) {
      return _then(_self.copyWith(hospital: value));
    });
  }
}

/// @nodoc
mixin _$DoctorProfile {
  String get id;
  String get mobile;
  @JsonKey(name: 'first_name')
  String? get firstName;
  @JsonKey(name: 'middle_name')
  String? get middleName;
  @JsonKey(name: 'last_name')
  String? get lastName;
  String? get email;
  List<Education> get educations;
  List<Speciality> get specialities;
  List<Experience> get experiences;
  @JsonKey(name: 'profile_completion')
  int get profileCompletion;
  Map<String, bool> get sections;

  /// Create a copy of DoctorProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DoctorProfileCopyWith<DoctorProfile> get copyWith =>
      _$DoctorProfileCopyWithImpl<DoctorProfile>(
          this as DoctorProfile, _$identity);

  /// Serializes this DoctorProfile to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DoctorProfile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mobile, mobile) || other.mobile == mobile) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.middleName, middleName) ||
                other.middleName == middleName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            const DeepCollectionEquality()
                .equals(other.educations, educations) &&
            const DeepCollectionEquality()
                .equals(other.specialities, specialities) &&
            const DeepCollectionEquality()
                .equals(other.experiences, experiences) &&
            (identical(other.profileCompletion, profileCompletion) ||
                other.profileCompletion == profileCompletion) &&
            const DeepCollectionEquality().equals(other.sections, sections));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      mobile,
      firstName,
      middleName,
      lastName,
      email,
      const DeepCollectionEquality().hash(educations),
      const DeepCollectionEquality().hash(specialities),
      const DeepCollectionEquality().hash(experiences),
      profileCompletion,
      const DeepCollectionEquality().hash(sections));

  @override
  String toString() {
    return 'DoctorProfile(id: $id, mobile: $mobile, firstName: $firstName, middleName: $middleName, lastName: $lastName, email: $email, educations: $educations, specialities: $specialities, experiences: $experiences, profileCompletion: $profileCompletion, sections: $sections)';
  }
}

/// @nodoc
abstract mixin class $DoctorProfileCopyWith<$Res> {
  factory $DoctorProfileCopyWith(
          DoctorProfile value, $Res Function(DoctorProfile) _then) =
      _$DoctorProfileCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String mobile,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'middle_name') String? middleName,
      @JsonKey(name: 'last_name') String? lastName,
      String? email,
      List<Education> educations,
      List<Speciality> specialities,
      List<Experience> experiences,
      @JsonKey(name: 'profile_completion') int profileCompletion,
      Map<String, bool> sections});
}

/// @nodoc
class _$DoctorProfileCopyWithImpl<$Res>
    implements $DoctorProfileCopyWith<$Res> {
  _$DoctorProfileCopyWithImpl(this._self, this._then);

  final DoctorProfile _self;
  final $Res Function(DoctorProfile) _then;

  /// Create a copy of DoctorProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mobile = null,
    Object? firstName = freezed,
    Object? middleName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? educations = null,
    Object? specialities = null,
    Object? experiences = null,
    Object? profileCompletion = null,
    Object? sections = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mobile: null == mobile
          ? _self.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      middleName: freezed == middleName
          ? _self.middleName
          : middleName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      educations: null == educations
          ? _self.educations
          : educations // ignore: cast_nullable_to_non_nullable
              as List<Education>,
      specialities: null == specialities
          ? _self.specialities
          : specialities // ignore: cast_nullable_to_non_nullable
              as List<Speciality>,
      experiences: null == experiences
          ? _self.experiences
          : experiences // ignore: cast_nullable_to_non_nullable
              as List<Experience>,
      profileCompletion: null == profileCompletion
          ? _self.profileCompletion
          : profileCompletion // ignore: cast_nullable_to_non_nullable
              as int,
      sections: null == sections
          ? _self.sections
          : sections // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ));
  }
}

/// Adds pattern-matching-related methods to [DoctorProfile].
extension DoctorProfilePatterns on DoctorProfile {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DoctorProfile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DoctorProfile() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DoctorProfile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorProfile():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DoctorProfile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorProfile() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String mobile,
            @JsonKey(name: 'first_name') String? firstName,
            @JsonKey(name: 'middle_name') String? middleName,
            @JsonKey(name: 'last_name') String? lastName,
            String? email,
            List<Education> educations,
            List<Speciality> specialities,
            List<Experience> experiences,
            @JsonKey(name: 'profile_completion') int profileCompletion,
            Map<String, bool> sections)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DoctorProfile() when $default != null:
        return $default(
            _that.id,
            _that.mobile,
            _that.firstName,
            _that.middleName,
            _that.lastName,
            _that.email,
            _that.educations,
            _that.specialities,
            _that.experiences,
            _that.profileCompletion,
            _that.sections);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String mobile,
            @JsonKey(name: 'first_name') String? firstName,
            @JsonKey(name: 'middle_name') String? middleName,
            @JsonKey(name: 'last_name') String? lastName,
            String? email,
            List<Education> educations,
            List<Speciality> specialities,
            List<Experience> experiences,
            @JsonKey(name: 'profile_completion') int profileCompletion,
            Map<String, bool> sections)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorProfile():
        return $default(
            _that.id,
            _that.mobile,
            _that.firstName,
            _that.middleName,
            _that.lastName,
            _that.email,
            _that.educations,
            _that.specialities,
            _that.experiences,
            _that.profileCompletion,
            _that.sections);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String mobile,
            @JsonKey(name: 'first_name') String? firstName,
            @JsonKey(name: 'middle_name') String? middleName,
            @JsonKey(name: 'last_name') String? lastName,
            String? email,
            List<Education> educations,
            List<Speciality> specialities,
            List<Experience> experiences,
            @JsonKey(name: 'profile_completion') int profileCompletion,
            Map<String, bool> sections)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DoctorProfile() when $default != null:
        return $default(
            _that.id,
            _that.mobile,
            _that.firstName,
            _that.middleName,
            _that.lastName,
            _that.email,
            _that.educations,
            _that.specialities,
            _that.experiences,
            _that.profileCompletion,
            _that.sections);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DoctorProfile implements DoctorProfile {
  const _DoctorProfile(
      {required this.id,
      required this.mobile,
      @JsonKey(name: 'first_name') this.firstName,
      @JsonKey(name: 'middle_name') this.middleName,
      @JsonKey(name: 'last_name') this.lastName,
      this.email,
      final List<Education> educations = const [],
      final List<Speciality> specialities = const [],
      final List<Experience> experiences = const [],
      @JsonKey(name: 'profile_completion') this.profileCompletion = 0,
      final Map<String, bool> sections = const {}})
      : _educations = educations,
        _specialities = specialities,
        _experiences = experiences,
        _sections = sections;
  factory _DoctorProfile.fromJson(Map<String, dynamic> json) =>
      _$DoctorProfileFromJson(json);

  @override
  final String id;
  @override
  final String mobile;
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;
  @override
  @JsonKey(name: 'middle_name')
  final String? middleName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  final String? email;
  final List<Education> _educations;
  @override
  @JsonKey()
  List<Education> get educations {
    if (_educations is EqualUnmodifiableListView) return _educations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_educations);
  }

  final List<Speciality> _specialities;
  @override
  @JsonKey()
  List<Speciality> get specialities {
    if (_specialities is EqualUnmodifiableListView) return _specialities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specialities);
  }

  final List<Experience> _experiences;
  @override
  @JsonKey()
  List<Experience> get experiences {
    if (_experiences is EqualUnmodifiableListView) return _experiences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_experiences);
  }

  @override
  @JsonKey(name: 'profile_completion')
  final int profileCompletion;
  final Map<String, bool> _sections;
  @override
  @JsonKey()
  Map<String, bool> get sections {
    if (_sections is EqualUnmodifiableMapView) return _sections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sections);
  }

  /// Create a copy of DoctorProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DoctorProfileCopyWith<_DoctorProfile> get copyWith =>
      __$DoctorProfileCopyWithImpl<_DoctorProfile>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DoctorProfileToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DoctorProfile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mobile, mobile) || other.mobile == mobile) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.middleName, middleName) ||
                other.middleName == middleName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            const DeepCollectionEquality()
                .equals(other._educations, _educations) &&
            const DeepCollectionEquality()
                .equals(other._specialities, _specialities) &&
            const DeepCollectionEquality()
                .equals(other._experiences, _experiences) &&
            (identical(other.profileCompletion, profileCompletion) ||
                other.profileCompletion == profileCompletion) &&
            const DeepCollectionEquality().equals(other._sections, _sections));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      mobile,
      firstName,
      middleName,
      lastName,
      email,
      const DeepCollectionEquality().hash(_educations),
      const DeepCollectionEquality().hash(_specialities),
      const DeepCollectionEquality().hash(_experiences),
      profileCompletion,
      const DeepCollectionEquality().hash(_sections));

  @override
  String toString() {
    return 'DoctorProfile(id: $id, mobile: $mobile, firstName: $firstName, middleName: $middleName, lastName: $lastName, email: $email, educations: $educations, specialities: $specialities, experiences: $experiences, profileCompletion: $profileCompletion, sections: $sections)';
  }
}

/// @nodoc
abstract mixin class _$DoctorProfileCopyWith<$Res>
    implements $DoctorProfileCopyWith<$Res> {
  factory _$DoctorProfileCopyWith(
          _DoctorProfile value, $Res Function(_DoctorProfile) _then) =
      __$DoctorProfileCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String mobile,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'middle_name') String? middleName,
      @JsonKey(name: 'last_name') String? lastName,
      String? email,
      List<Education> educations,
      List<Speciality> specialities,
      List<Experience> experiences,
      @JsonKey(name: 'profile_completion') int profileCompletion,
      Map<String, bool> sections});
}

/// @nodoc
class __$DoctorProfileCopyWithImpl<$Res>
    implements _$DoctorProfileCopyWith<$Res> {
  __$DoctorProfileCopyWithImpl(this._self, this._then);

  final _DoctorProfile _self;
  final $Res Function(_DoctorProfile) _then;

  /// Create a copy of DoctorProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? mobile = null,
    Object? firstName = freezed,
    Object? middleName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? educations = null,
    Object? specialities = null,
    Object? experiences = null,
    Object? profileCompletion = null,
    Object? sections = null,
  }) {
    return _then(_DoctorProfile(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mobile: null == mobile
          ? _self.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      middleName: freezed == middleName
          ? _self.middleName
          : middleName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      educations: null == educations
          ? _self._educations
          : educations // ignore: cast_nullable_to_non_nullable
              as List<Education>,
      specialities: null == specialities
          ? _self._specialities
          : specialities // ignore: cast_nullable_to_non_nullable
              as List<Speciality>,
      experiences: null == experiences
          ? _self._experiences
          : experiences // ignore: cast_nullable_to_non_nullable
              as List<Experience>,
      profileCompletion: null == profileCompletion
          ? _self.profileCompletion
          : profileCompletion // ignore: cast_nullable_to_non_nullable
              as int,
      sections: null == sections
          ? _self._sections
          : sections // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ));
  }
}

/// @nodoc
mixin _$CatalogItem {
  String get id;
  String get name;

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CatalogItemCopyWith<CatalogItem> get copyWith =>
      _$CatalogItemCopyWithImpl<CatalogItem>(this as CatalogItem, _$identity);

  /// Serializes this CatalogItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CatalogItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @override
  String toString() {
    return 'CatalogItem(id: $id, name: $name)';
  }
}

/// @nodoc
abstract mixin class $CatalogItemCopyWith<$Res> {
  factory $CatalogItemCopyWith(
          CatalogItem value, $Res Function(CatalogItem) _then) =
      _$CatalogItemCopyWithImpl;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$CatalogItemCopyWithImpl<$Res> implements $CatalogItemCopyWith<$Res> {
  _$CatalogItemCopyWithImpl(this._self, this._then);

  final CatalogItem _self;
  final $Res Function(CatalogItem) _then;

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [CatalogItem].
extension CatalogItemPatterns on CatalogItem {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CatalogItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CatalogItem() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_CatalogItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogItem():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CatalogItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogItem() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String name)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CatalogItem() when $default != null:
        return $default(_that.id, _that.name);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String name) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogItem():
        return $default(_that.id, _that.name);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String name)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogItem() when $default != null:
        return $default(_that.id, _that.name);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CatalogItem implements CatalogItem {
  const _CatalogItem({required this.id, required this.name});
  factory _CatalogItem.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemFromJson(json);

  @override
  final String id;
  @override
  final String name;

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CatalogItemCopyWith<_CatalogItem> get copyWith =>
      __$CatalogItemCopyWithImpl<_CatalogItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CatalogItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CatalogItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @override
  String toString() {
    return 'CatalogItem(id: $id, name: $name)';
  }
}

/// @nodoc
abstract mixin class _$CatalogItemCopyWith<$Res>
    implements $CatalogItemCopyWith<$Res> {
  factory _$CatalogItemCopyWith(
          _CatalogItem value, $Res Function(_CatalogItem) _then) =
      __$CatalogItemCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$CatalogItemCopyWithImpl<$Res> implements _$CatalogItemCopyWith<$Res> {
  __$CatalogItemCopyWithImpl(this._self, this._then);

  final _CatalogItem _self;
  final $Res Function(_CatalogItem) _then;

  /// Create a copy of CatalogItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_CatalogItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
