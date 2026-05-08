import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class AppUser {
  final String? id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  AppUser({
    this.id,
    required this.email,
    required this.name,
    required this.role,
    DateTime? createdAt,
    this.lastLoginAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'staff'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }
}