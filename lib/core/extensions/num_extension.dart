import 'package:intl/intl.dart' show NumberFormat;

extension NumExtension on num {
  /// Returns a compact string representation of the number.
  ///
  /// - If the number is below 10,000, it returns the number formatted with commas.
  /// - For numbers 10,000 or above, it shows:
  ///   - "k" for thousands (e.g. 10500 -> "10.5k")
  ///   - "m" for millions (e.g. 1100000 -> "1.1m")
  ///   - "b" for billions (e.g. 1150000000 -> "1.2b")
  String toCountFormat() {
    if (this < 10000) {
      // Formats the number with comma as thousands separator.
      return NumberFormat.decimalPattern().format(this);
    } else if (this < 1000000) {
      // Format in thousands.
      final result = this / 1000;
      return result % 1 == 0
          ? '${result.toInt()}k'
          : '${result.toStringAsFixed(1)}k';
    } else if (this < 1000000000) {
      // Format in millions.
      final result = this / 1000000;
      return result % 1 == 0
          ? '${result.toInt()}m'
          : '${result.toStringAsFixed(1)}m';
    } else {
      // Format in billions.
      final result = this / 1000000000;
      return result % 1 == 0
          ? '${result.toInt()}b'
          : '${result.toStringAsFixed(1)}b';
    }
  }
}
