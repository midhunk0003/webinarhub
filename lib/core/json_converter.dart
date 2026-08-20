String? stringFromJson(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

dynamic stringToJson(String? value) => value;
