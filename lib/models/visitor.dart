import 'package:cloud_firestore/cloud_firestore.dart';

class Visitor {
  final String? id;
  final String name;
  final String ninNumber;
  final String contact;
  final String personToVisit;
  final String relationship;
  final String district;
  final String subcounty;
  final String village;
  final String reason;
  final String itemsBrought;
  final double cashBrought;
  final DateTime timeIn;
  final DateTime? timeOut;
  final String status; // 'checked_in', 'checked_out', 'pending'
  final String? staffId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Visitor({
    this.id,
    required this.name,
    required this.ninNumber,
    required this.contact,
    required this.personToVisit,
    required this.relationship,
    required this.district,
    required this.subcounty,
    required this.village,
    required this.reason,
    required this.itemsBrought,
    required this.cashBrought,
    required this.timeIn,
    this.timeOut,
    this.status = 'checked_in',
    this.staffId,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Duration? get visitDuration {
    if (timeOut != null) {
      return timeOut!.difference(timeIn);
    }
    return DateTime.now().difference(timeIn);
  }

  String get formattedDuration {
    final duration = visitDuration;
    if (duration == null) return 'Ongoing';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ninNumber': ninNumber,
      'contact': contact,
      'personToVisit': personToVisit,
      'relationship': relationship,
      'district': district,
      'subcounty': subcounty,
      'village': village,
      'reason': reason,
      'itemsBrought': itemsBrought,
      'cashBrought': cashBrought,
      'timeIn': Timestamp.fromDate(timeIn),
      'timeOut': timeOut != null ? Timestamp.fromDate(timeOut!) : null,
      'status': status,
      'staffId': staffId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  factory Visitor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Visitor(
      id: doc.id,
      name: data['name'] ?? '',
      ninNumber: data['ninNumber'] ?? '',
      contact: data['contact'] ?? '',
      personToVisit: data['personToVisit'] ?? '',
      relationship: data['relationship'] ?? '',
      district: data['district'] ?? '',
      subcounty: data['subcounty'] ?? '',
      village: data['village'] ?? '',
      reason: data['reason'] ?? '',
      itemsBrought: data['itemsBrought'] ?? '',
      cashBrought: (data['cashBrought'] ?? 0.0).toDouble(),
      timeIn: (data['timeIn'] as Timestamp).toDate(),
      timeOut: data['timeOut'] != null
          ? (data['timeOut'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'checked_in',
      staffId: data['staffId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Visitor copyWith({
    String? name,
    String? ninNumber,
    String? contact,
    String? personToVisit,
    String? relationship,
    String? district,
    String? subcounty,
    String? village,
    String? reason,
    String? itemsBrought,
    double? cashBrought,
    DateTime? timeIn,
    DateTime? timeOut,
    String? status,
    String? staffId,
  }) {
    return Visitor(
      id: id,
      name: name ?? this.name,
      ninNumber: ninNumber ?? this.ninNumber,
      contact: contact ?? this.contact,
      personToVisit: personToVisit ?? this.personToVisit,
      relationship: relationship ?? this.relationship,
      district: district ?? this.district,
      subcounty: subcounty ?? this.subcounty,
      village: village ?? this.village,
      reason: reason ?? this.reason,
      itemsBrought: itemsBrought ?? this.itemsBrought,
      cashBrought: cashBrought ?? this.cashBrought,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      status: status ?? this.status,
      staffId: staffId ?? this.staffId,
    );
  }
}
