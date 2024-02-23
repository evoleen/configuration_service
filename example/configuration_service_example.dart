import 'package:configuration_service/configuration_service.dart';

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

  final authVerifyToken = ConfigurationValue<bool>(
    name: "auth.verify_token",
    defaultValue: const Optional(true),
  );

  MyConfigurationService() {
    // register all configuration values so that they are picked up by the loader
    register(enableGraphQLPlayground);
    register(enableIntrospection);
    register(enableSchemaDownload);
    register(authVerifyToken);
  }
}

void main() async {
  final configurationService = MyConfigurationService();

  await configurationService.loadFromJson(filePath: 'config.json');

  print(
      'auth.verify_token was present in the configuration file: ${configurationService.authVerifyToken.hasValue(ignoreDefault: true)}');
  print(
      'auth.verify_token has a value (default or explicit): ${configurationService.authVerifyToken.hasValue()}');
  print(
      'auth.verify_token is set to: ${configurationService.authVerifyToken.value}');
}
