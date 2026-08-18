/// Converts Firestore inventory values to a safe integer quantity.
int parseInventoryQuantity(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
