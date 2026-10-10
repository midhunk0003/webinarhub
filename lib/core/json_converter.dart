String? stringFromJson(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

dynamic stringToJson(String? value) => value;

List<String>? stringListFromJson(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }

  return [value.toString()];
}
