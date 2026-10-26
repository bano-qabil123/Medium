class Validators {
  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    if (!value.isValidEmail) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Validate password
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }
  
  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  /// Validate username
  static String? validateUsername(String? value, {int minLength = 3, int maxLength = 20}) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < minLength) {
      return 'Username must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return 'Username must be less than $maxLength characters';
    }
    if (!value.isValidUsername) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }
  
  /// Validate display name
  static String? validateDisplayName(String? value, {int minLength = 2, int maxLength = 50}) {
    if (value == null || value.isEmpty) {
      return 'Please enter a display name';
    }
    if (value.length < minLength) {
      return 'Display name must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return 'Display name must be less than $maxLength characters';
    }
    return null;
  }
  
  /// Validate bio
  static String? validateBio(String? value, {int maxLength = 500}) {
    if (value != null && value.length > maxLength) {
      return 'Bio must be less than $maxLength characters';
    }
    return null;
  }
  
  /// Validate article title
  static String? validateArticleTitle(String? value, {int minLength = 5, int maxLength = 120}) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    if (value.length < minLength) {
      return 'Title must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return 'Title must be less than $maxLength characters';
    }
    return null;
  }
  
  /// Validate article content
  static String? validateArticleContent(String? value, {int minLength = 50}) {
    if (value == null || value.isEmpty) {
      return 'Please enter some content';
    }
    if (value.length < minLength) {
      return 'Content must be at least $minLength characters';
    }
    return null;
  }
  
  /// Validate comment
  static String? validateComment(String? value, {int minLength = 1, int maxLength = 2000}) {
    if (value == null || value.isEmpty) {
      return 'Please enter a comment';
    }
    if (value.length < minLength) {
      return 'Comment must be at least $minLength character';
    }
    if (value.length > maxLength) {
      return 'Comment must be less than $maxLength characters';
    }
    return null;
  }
  
  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    if (!value.isValidUrl) {
      return 'Please enter a valid URL';
    }
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }
  
  /// Validate length
  static String? validateLength(String? value, {int? min, int? max, String? fieldName}) {
    final name = fieldName ?? 'Field';
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (min != null && value.length < min) {
      return '$name must be at least $min characters';
    }
    if (max != null && value.length > max) {
      return '$name must be less than $max characters';
    }
    return null;
  }
  
  /// Validate that a value is not empty
  static bool isNotEmpty(String? value) => value != null && value.isNotEmpty;
  
  /// Validate that a value is empty
  static bool isEmpty(String? value) => value == null || value.isEmpty;
}
