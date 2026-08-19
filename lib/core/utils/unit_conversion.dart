class UnitConversion {
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  static double kmhToMph(double kmh) {
    return kmh * 0.621371;
  }

  static double kmhToMs(double kmh) {
    return kmh / 3.6;
  }

  static double kmhToKnots(double kmh) {
    return kmh * 0.539957;
  }

  static double metersToKm(double meters) {
    return meters / 1000;
  }

  static double metersToMiles(double meters) {
    return meters * 0.000621371;
  }
}
