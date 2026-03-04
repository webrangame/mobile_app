class UserUtils {
  /// Detects if a string is an encrypted PII string (AWS KMS format).
  /// Format: base64::base64::base64
  static bool isEncrypted(String? text) {
    if (text == null || text.isEmpty) return false;
    // AWS KMS PII format uses :: separator between Data Key, Nonce, and Ciphertext
    return text.contains('::');
  }

  /// Returns a display-friendly username.
  /// If the name is encrypted, it returns 'Anonymous' or a masked version.
  static String formatUserName(String? name) {
    if (name == null || name.isEmpty) return 'Anonymous';
    if (isEncrypted(name)) {
      // Return a placeholder for encrypted names to avoid showing internal technical strings
      return 'User';
    }
    return name;
  }

  /// Returns a display-friendly email.
  static String formatEmail(String? email) {
    if (email == null || email.isEmpty) return '';
    if (isEncrypted(email)) {
      return '(Encrypted)';
    }
    return email;
  }

  /// Returns initials for an avatar.
  static String getInitials(String? name) {
    final cleanName = formatUserName(name);
    if (cleanName.isEmpty) return 'U';
    return cleanName[0].toUpperCase();
  }
}
