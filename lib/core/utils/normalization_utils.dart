class NormalizationUtils {
  static String normalizeName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? normalizePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;
    
    // Remove all non-numeric characters
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    
    // Tunisian phone numbers are 8 digits.
    // If it has a prefix like 216, take the last 8 digits.
    if (digits.length >= 8) {
      return digits.substring(digits.length - 8);
    }
    
    return digits;
  }
}
