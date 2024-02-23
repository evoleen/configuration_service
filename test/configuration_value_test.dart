import 'package:configuration_service/configuration_service.dart';
import 'package:test/test.dart';

void main() {
  group('Test ConfigurationValue', () {
    test('ConfigurationValue without value reports hasValue == false', () {
      final configurationValue = ConfigurationValue<bool>(name: "test_value");
      expect(configurationValue.hasValue(), false);
    });

    test('ConfigurationValue with value reports hasValue == true', () {
      final configurationValue = ConfigurationValue<bool>(name: "test_value");
      configurationValue.value = true;
      expect(configurationValue.hasValue(), true);
    });

    test(
        'ConfigurationValue without value reports hasValue == true if it has a default',
        () {
      final configurationValue = ConfigurationValue<bool>(
        name: "test_value",
        defaultValue: Optional(true),
      );

      expect(configurationValue.hasValue(), true);
    });

    test(
        'ConfigurationValue without value reports hasValue == false if it has a default but needs to ignore the default',
        () {
      final configurationValue = ConfigurationValue<bool>(
        name: "test_value",
        defaultValue: Optional(true),
      );

      expect(configurationValue.hasValue(ignoreDefault: true), false);
    });

    test(
        'ConfigurationValue without value reports hasValue == true if it has a default, needs to ignore the default but a value was set',
        () {
      final configurationValue = ConfigurationValue<bool>(
        name: "test_value",
        defaultValue: Optional(true),
      );

      configurationValue.value = true;

      expect(configurationValue.hasValue(ignoreDefault: true), true);
    });

    test('ConfigurationValue returns the value that was written to it', () {
      final configurationValue = ConfigurationValue<String>(
        name: "test_value",
        defaultValue: Optional("1234"),
      );

      expect(configurationValue.value, "1234");

      configurationValue.value = "5678";

      expect(configurationValue.value, "5678");
    });
  });
}
