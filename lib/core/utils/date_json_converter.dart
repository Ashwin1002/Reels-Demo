import 'package:freezed_annotation/freezed_annotation.dart';

class DateTimeConverter extends JsonConverter<DateTime, String> {
  const DateTimeConverter();
  @override
  DateTime fromJson(String json) {
    final date = DateTime.parse(json);
    return date.isUtc ? date.toLocal() : date;
  }

  @override
  String toJson(DateTime object) {
    return object.toIso8601String();
  }
}
