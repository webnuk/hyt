/// Laravel serializes some numeric fields as JSON strings (decimal-cast
/// attributes come through as `"4.50"`, not `4.5`), and it's inconsistent
/// about which ones — so every numeric field coming from the API needs to
/// tolerate either shape rather than assuming `num`.
double parseDouble(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

int parseInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? double.tryParse(value.toString())?.toInt() ?? fallback;
}
