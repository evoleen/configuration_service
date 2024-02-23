/// Defines an optional value. An optional value can distinguish between
/// whether a value has been assigned ([isSet]) or not. Construct an
/// optional that has a value by using the unnamed constructor, such as
/// [Optional<int>(10)]. An optional without value can be created by using
/// [Optional.none()]
class Optional<T> {
  /// Whether a value has been set or not
  final bool isSet;

  /// Private container for the value
  final T? _value;

  /// Returns whether [other] equals [this]
  @override
  bool operator ==(Object other) {
    return other is Optional && isSet == other.isSet && _value == other._value;
  }

  @override
  int get hashCode => _value.hashCode;

  /// Will return the value of [this]. Throws an exception if [isSet] equals
  /// false.
  T get value {
    if (!isSet) {
      throw Exception('Tried accessing an optional value that was never set.');
    }

    return _value!;
  }

  /// Constructor to build an optional with a value.
  const Optional(T v)
      : isSet = true,
        _value = v;

  /// Constructor to build an optional without value.
  const Optional.none()
      : isSet = false,
        _value = null;
}
