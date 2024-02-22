import 'package:configuration_service/src/optional.dart';

/// Stores a configuration value that can be read from or written to a
/// configuration file.
class ConfigurationValue<T> {
  final Type type = T;

  /// Returns if a value is available. Ignores any default value if
  /// [ignoreDefault] is set to true. Can be used to determine if a value
  /// has been loaded from a file or not.
  bool hasValue({bool ignoreDefault = false}) {
    return _currentValue != const Optional.none() ||
        (!ignoreDefault && defaultValue != const Optional.none());
  }

  /// Returns the stored value. Will throw an exception if no value has been
  /// read and no default value is available.
  T get value {
    // check the currently set value first
    if (_currentValue != const Optional.none()) {
      return _currentValue.value;
    }

    // if no value has been set, try returning the default value
    if (defaultValue != const Optional.none()) {
      return defaultValue.value;
    }

    // if both fail, throw an exception
    throw Exception(
        'Tried to access configuration value $name but it is not set and also does not have a default value.');
  }

  /// Set current value to [v]
  set value(T v) {
    _currentValue = Optional<T>(v);
  }

  Optional<T> _currentValue = const Optional.none();

  /// Name of the variable. The name can optionally contain a hierarchy, for
  /// example "auth.jwks_url" which will place the value in the section "auth"
  /// when exported to JSON. When reading from environment variables, it will
  /// automatically be converted to a prefix such as "AUTH_JWKS_URL".
  final String name;

  /// Default value to use if no value has been read so far.
  final Optional<T> defaultValue;

  /// Whether this value is required. This will cause validation to fail if
  /// a config file is read but the value does not exist. The flag is helpful
  /// if no sane default can be supplied.
  final bool isRequired;

  ConfigurationValue({
    required this.name,
    this.defaultValue = const Optional.none(),
    this.isRequired = false,
  });
}
