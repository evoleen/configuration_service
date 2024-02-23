<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Enables applications to make effective use of JSON configuration files.
Especially useful for backend services or CLI tools written in Dart but can
also be used with Flutter.

## Features

- Type-safe processing of JSON configuration files
- No need for code generation
- Handles optional and required values
- Can use defaults if values are missing
- Supports environment variables (great to inject secrets)

## Getting started

Assume a configuration file `config.json` with the following contents:

```json
{
    "enable_graphql_playground": true,
    "enable_introspection": true,
    "enable_schema_download": true
}
```

To load such a configuration file in your application, create a class
`MyConfigurationService` that extends `ConfigurationService` and defines
typed properties for every configuration value you want to support:

```dart
class MyConfigurationService extends ConfigurationService {
  // ConfigurationValue<bool> defines a boolean value. You can use bool,
  // int, String, List<> as well as your own complex types (more below).
  final enableGraphQLPlayground = ConfigurationValue<bool>(
    // name of the value in the configuration file
    name: "enable_graphql_playground",
    // optionally specify a default that will be used the value doesn't exist in the configuration file
    defaultValue: const Optional(false),
  );

  final enableIntrospection = ConfigurationValue<bool>(
    name: "enable_introspection",
    // Values can be marked as required. This will throw an exception if the value is missing in the configuration file.
    isRequired: true,
  );

  final enableSchemaDownload = ConfigurationValue<bool>(
    name: "enable_schema_download",
    defaultValue: const Optional(false),
  );

  MyConfigurationService() {
    // register all configuration values so that they are picked up by the loader
    register(enableGraphQLPlayground);
    register(enableIntrospection);
    register(enableSchemaDownload);
  }
}
```

Load the configuration file with `loadFromJson()`:

```dart
void main() async {
  final configurationService = MyConfigurationService();
  await configurationService.loadFromJson(filePath: 'config.json');

  print(configurationService.enableIntrospection.value);
}
```

## Usage

### Access a value from the configuration file

Assume the following configuration file exists:

```json
{ "test": true }
```

The following code will read it:

```dart
final configurationValue = ConfigurationValue<bool>(name: 'test');

final configurationService = ConfigurationService();
configurationService.register(configurationValue);
await configurationService.loadFromJson(filePath: 'config.json');

print(configurationValue.value); // "true"
```

### Check if a value exists

```dart
final configurationValue = ConfigurationValue<bool>(name: 'test');

final configurationService = ConfigurationService();
configurationService.register(configurationValue);
await configurationService.loadFromJson(filePath: 'config.json');

print(configurationValue.hasValue()); // "true" if value exists in config.json
```

### Use defaults

```dart
final configurationValue = ConfigurationValue<bool>(name: 'test', defaultValue = Optional(true));

final configurationService = ConfigurationService();
configurationService.register(configurationValue);
await configurationService.loadFromJson(filePath: 'config.json');

print(configurationValue.hasValue()); // "true" even if it doesn't exist in config.json
print(configurationValue.hasValue(ignoreDefaults: true)); // only "true" if it exists in config.json
```

### Mark values as required

```dart
final configurationValue = ConfigurationValue<bool>(name: 'test', isRequired: true);

final configurationService = ConfigurationService();
configurationService.register(configurationValue);

// will throw an exception if "test" can't be found in the file
await configurationService.loadFromJson(filePath: 'config.json');

print(configurationValue.value);
```

### Allow overrides from environment variables

Using `allowEnvironmentOverrides` gives precedence to values found in the environment.
Names of environment variables are determined by re-casing the configuration value's name
to `CONSTANT_CASE`.

Examples:
- `verify_token` becomes `VERIFY_TOKEN`
- `auth.verify_token` becomes `AUTH_VERIFY_TOKEN`

```dart
final configurationValue = ConfigurationValue<bool>(name: 'test', isRequired: true);

final configurationService = ConfigurationService();
configurationService.register(configurationValue);

await configurationService.loadFromJson(filePath: 'config.json', allowEnvironmentOverrides: true);

print(configurationValue.value); // value that was found in env variable TEST, otherwise value from config file
```

### Using configuration file sections

It is often desirable to partition a configuration file in section for better maintainability.
A hierarchy of configuration value can be specified by using the dot notation.

Assume the following configuration file:

```json
{
  "auth": {
    "verify_token": true
  }
}
```

The value can be accessed by specifying `auth.verify_token` as its name.

### Using complex types

`configuration_service` understands `int`, `String` and `bool` natively as well as
corresponding `List` types. To load custom complex types, specify a deserializer
when registering the type:

```dart
configurationService.register(authEntityIdFallback, deserializers: {
      EntityIdFallbackConfig: EntityIdFallbackConfig.fromJson,
    });
```

This allows loading arbitrarily structured data from the configuration file. Make sure
that the `fromJson` method uses correct json keys to access the values from the
configuration data.
