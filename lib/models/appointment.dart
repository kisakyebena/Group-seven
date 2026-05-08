import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String? id;
  final String visitorName;
  final String visitorContact;
  final String visitorNin;
  final String personToVisit;
  final DateTime appointmentDate;
  final String purpose;
  final String status; // 'pending', 'approved', 'completed', 'cancelled'
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    this.id,
    required this.visitorName,
    required this.visitorContact,
    required this.visitorNin,
    required this.personToVisit,
    required this.appointmentDate,
    required this.purpose,
    this.status = 'pending',
    this.approvedBy,
    this.approvedAt,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isUpcoming => appointmentDate.isAfter(DateTime.now());
  bool get isPast => appointmentDate.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'visitorName': visitorName,
      'visitorContact': visitorContact,
      'visitorNin': visitorNin,
      'personToVisit': personToVisit,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'purpose': purpose,
      'status': status,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      visitorName: data['visitorName'] ?? '',
      visitorContact: data['visitorContact'] ?? '',
      visitorNin: data['visitorNin'] ?? '',
      personToVisit: data['personToVisit'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      purpose: data['purpose'] ?? '',
      status: data['status'] ?? 'pending',
      approvedBy: data['approvedBy'],
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
