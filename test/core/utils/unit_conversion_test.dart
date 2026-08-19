import 'package:flutter_test/flutter_test.dart';
import 'package:drizzle/core/utils/unit_conversion.dart';

void main() {
  group('UnitConversion', () {
    test('should convert Celsius to Fahrenheit', () {
      expect(UnitConversion.celsiusToFahrenheit(0), 32);
      expect(UnitConversion.celsiusToFahrenheit(100), 212);
      expect(UnitConversion.celsiusToFahrenheit(-40), -40);
    });

    test('should convert Fahrenheit to Celsius', () {
      expect(UnitConversion.fahrenheitToCelsius(32), 0);
      expect(UnitConversion.fahrenheitToCelsius(212), 100);
      expect(UnitConversion.fahrenheitToCelsius(-40), -40);
    });

    test('should convert km/h to mph', () {
      expect(UnitConversion.kmhToMph(100), closeTo(62.1371, 0.01));
    });

    test('should convert km/h to m/s', () {
      expect(UnitConversion.kmhToMs(36), 10.0);
    });

    test('should convert km/h to knots', () {
      expect(UnitConversion.kmhToKnots(100), closeTo(53.9957, 0.01));
    });

    test('should convert meters to km', () {
      expect(UnitConversion.metersToKm(1000), 1.0);
      expect(UnitConversion.metersToKm(5000), 5.0);
    });

    test('should convert meters to miles', () {
      expect(UnitConversion.metersToMiles(1609.34), closeTo(1.0, 0.01));
    });
  });
}
