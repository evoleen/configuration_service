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

```
{
    "enable_graphql_playground": true,
    "enable_introspection": true,
    "enable_schema_download": true
}
```

To load such a configuration file in your application, create a class
`MyConfigurationService` that extends `ConfigurationService` and defines
typed properties for every configuration value you want to support:

```
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

```
void main() async {
  final configurationService = MyConfigurationService();
  await configurationService.loadFromJson(filePath: 'config.json');

  print(configurationService.enableIntrospection.value);
}
```

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```
