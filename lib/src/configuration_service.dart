import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:configuration_service/src/configuration_value.dart';
import 'package:recase/recase.dart';

/// Derive from this class to create a configuration service. Add
/// any values as properties of this class using [ConfigurationValue].
/// Register all values in the constructor with [register] to ensure
/// they are picked up when loading the configuration file.
class ConfigurationService {
  final List<ConfigurationValue> _values = [];
  final Map<Type, Function> _deserializers = {};

  /// Registers ConfigurationValue [value] with the service.
  /// If the value uses a custom type, [deserializers] can be
  /// used to pass corresponding fromJson() methods in order
  /// to deserialize the types when reading values from a configuration
  /// file.
  void register(ConfigurationValue value,
      {Map<Type, Function> deserializers = const {}}) {
    // add value if it's not registered yet
    if (_values.firstWhereOrNull((element) => element.name == value.name) ==
        null) {
      _values.add(value);
    }

    // add all deserializers
    _deserializers.addAll(deserializers);
  }

  /// Returns a configuration value identified by [key] from [dataStore].
  /// Will return null if the value does not exist.
  /// Hierarchical values can be accessed through dot notation, such as
  /// "auth.verifyToken".
  dynamic _get({required String key, required Map<String, dynamic> dataStore}) {
    final valueHierarchy = key.split(".");

    var store = Map.from(dataStore);
    while (valueHierarchy.length > 1) {
      final step = valueHierarchy.removeAt(0);

      if (!store.containsKey(step)) {
        // the requested sub-tree doesn't exist
        return null;
      }

      store = store[step];
    }

    if (!store.containsKey(valueHierarchy.last)) {
      // the requested value doesn't exist
      return null;
    }

    return store[valueHierarchy.last];
  }

  /// Helper to cast a dynamic value to type [T] if it is atomic
  /// or call T.fromJson() on it to reconstruct the type.
  dynamic _decode<T>(dynamic input, Type type) {
    // if we have a registered deserializer for the type, use it
    if (_deserializers.keys.contains(type)) {
      return _deserializers[type]!(input);
    }

    if (input is String) {
      if (type == int) {
        return int.parse(input);
      } else if (type == bool) {
        return input == "1" || input == "true";
      } else {
        return input;
      }
    } else if (input is int) {
      if (type == String) {
        return input.toString();
      } else if (type == bool) {
        return input == 1;
      } else {
        return input;
      }
    } else if (input is bool) {
      if (type == String) {
        return input ? "true" : "false";
      } else if (type == int) {
        return input ? 1 : 0;
      }
    }

    // for lists, return the list itself
    if (input is List) {
      if (type == List<int>) {
        return List<int>.from(input.map((e) => e as int));
      } else if (type == List<String>) {
        return List<String>.from(input.map((e) => e as String));
      } else if (type == List<bool>) {
        return List<bool>.from(input.map((e) => e as bool));
      }
    }

    throw Exception('Unable to decode entry $input');
  }

  /// Loads all configuration values from the file located at [filePath].
  /// [validate] controls if a check will be perfomed whether all required
  /// values have been found in the configuration file. Throws an exception
  /// if validation fails.
  /// [allowEnvironmentOverrides] enables the use of environment variables
  /// in addition to the configuration file. Content from environment variables
  /// takes precedence. Useful when having to inject secrets into the
  /// configuration (such as API keys or certificates). Should only be used
  /// if control of the environment can be guaranteed.
  /// [configurationEnvironmentVariable] can optionally point to a variable
  /// from which to load the entire configuration JSON object. Enables use
  /// cases where configuration is not stored in a file but will be passed
  /// through environment. If this setting is not null and the referenced
  /// environment variable has content, it will be used instead of [filePath].
  /// Indidivual overrides through [allowEnvironmentOverrides] still work in
  /// addition.
  ///
  /// Throws an exception when unable to load / decode the configuration file
  /// or if validation shows that a required value was missing and no default
  /// exists.
  Future<void> loadFromJson({
    required String filePath,
    bool validate = true,
    bool allowEnvironmentOverrides = false,
    String? configurationEnvironmentVariable,
  }) async {
    String input;

    if (configurationEnvironmentVariable != null &&
        Platform.environment[configurationEnvironmentVariable] != null) {
      input = Platform.environment[configurationEnvironmentVariable] ?? '';
    } else {
      input = await File(filePath).readAsString();
    }

    final decodedData = jsonDecode(input);

    // decode data for all registered configuration values
    for (final value in _values) {
      var configurationData = _get(key: value.name, dataStore: decodedData);

      if (allowEnvironmentOverrides) {
        if (Platform.environment.containsKey(value.name.constantCase)) {
          configurationData = Platform.environment[value.name.constantCase];
        }
      }

      // if we receive a null value, the requested value did not exist
      if (configurationData == null) {
        continue;
      }

      value.value = _decode(configurationData, value.type);
    }

    // after everything is done, check if all required items have a value
    // assigned
    for (final value in _values) {
      if (value.isRequired && !value.hasValue(ignoreDefault: true)) {
        throw Exception(
            "Required configuration value ${value.name} wasn't found.");
      }
    }
  }
}
