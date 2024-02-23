import 'package:configuration_service/configuration_service.dart';
import 'package:test/test.dart';

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

void main() {
  group('Test ConfigurationService', () {
    test('ConfigurationService successfully loads test file', () async {
      final configurationService = MyConfigurationService();
      await configurationService.loadFromJson(filePath: 'test/config.json');
      expect(true, true);
    });

    test('ConfigurationService finds expected values in test file', () async {
      final configurationService = MyConfigurationService();
      await configurationService.loadFromJson(filePath: 'test/config.json');
      expect(configurationService.enableGraphQLPlayground.value, true);
      expect(configurationService.enableSchemaDownload.value, true);
      expect(configurationService.enableIntrospection.value, true);
    });

    test('ConfigurationService will complain about missing value', () async {
      final configurationService = MyConfigurationService();
      configurationService
          .register(ConfigurationValue(name: "test", isRequired: true));

      var exceptionTriggered = false;

      try {
        await configurationService.loadFromJson(filePath: 'test/config.json');
      } catch (_) {
        exceptionTriggered = true;
      }

      expect(exceptionTriggered, true);
    });

    // The following test can be run by executing `AUTH_NEEDED_FROM_ENVIRONMENT=test dart test`
    /*
    test('ConfigurationService will allow data from environment', () async {
      final envValue = ConfigurationValue<String>(
          name: "auth.needed_from_environment", isRequired: true);

      final configurationService = MyConfigurationService();
      configurationService.register(envValue);

      var exceptionTriggered = false;

      try {
        await configurationService.loadFromJson(
          filePath: 'test/config.json',
          allowEnvironmentOverrides: true,
        );
      } catch (_) {
        exceptionTriggered = true;
      }

      expect(exceptionTriggered, false);
      expect(envValue.value, "test");
    });
    */
  });
}
