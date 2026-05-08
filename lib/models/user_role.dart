enum UserRole {
  admin,
  staff;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.staff:
        return 'Staff';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
        return UserRole.staff;
      default:
        return UserRole.staff;
    }
  }
}