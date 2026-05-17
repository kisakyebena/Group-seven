import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visitor.dart';
import '../models/appointment.dart';

class VisitorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _visitorsRef => _firestore.collection('visitors');
  CollectionReference get _appointmentsRef =>
      _firestore.collection('appointments');

  // Visitor Operations
  Future<String> addVisitor(Visitor visitor) async {
    final docRef = await _visitorsRef.add(visitor.toFirestore());
    return docRef.id;
  }

  Future<void> updateVisitor(Visitor visitor) async {
    await _visitorsRef.doc(visitor.id).update(visitor.toFirestore());
  }

  Stream<List<Visitor>> getVisitorsStream({String? status}) {
    Query query = _visitorsRef.orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Visitor.fromFirestore(doc)).toList();
    });
  }

  Future<List<Visitor>> getTodayVisitors() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _visitorsRef
        .where('timeIn', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timeIn', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.map((doc) => Visitor.fromFirestore(doc)).toList();
  }

  Future<void> checkoutVisitor(String visitorId) async {
    await _visitorsRef.doc(visitorId).update({
      'timeOut': Timestamp.fromDate(DateTime.now()),
      'status': 'checked_out',
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteVisitor(String visitorId) async {
    await _visitorsRef.doc(visitorId).delete();
  }

  Stream<Visitor?> getVisitorStream(String visitorId) {
    return _visitorsRef.doc(visitorId).snapshots().map((doc) {
      if (doc.exists) {
        return Visitor.fromFirestore(doc);
      }
      return null;
    });
  }

  // Statistics
  Future<Map<String, dynamic>> getVisitorStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);

    final totalVisitors = await _visitorsRef.get();
    final todayVisitors = await _visitorsRef
        .where('timeIn', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();
    final monthlyVisitors = await _visitorsRef
        .where('timeIn',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();
    final checkedIn =
        await _visitorsRef.where('status', isEqualTo: 'checked_in').get();

    return {
      'total': totalVisitors.size,
      'today': todayVisitors.size,
      'thisMonth': monthlyVisitors.size,
      'checkedIn': checkedIn.size,
    };
  }

  // Appointment Operations
  Future<String> scheduleAppointment(Appointment appointment) async {
    final docRef = await _appointmentsRef.add(appointment.toFirestore());
    return docRef.id;
  }

  Stream<List<Appointment>> getAppointmentsStream({String? status}) {
    Query query =
        _appointmentsRef.orderBy('appointmentDate', descending: false);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status, {
    String? approvedBy,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == 'approved') {
      updates['approvedBy'] = approvedBy;
      updates['approvedAt'] = FieldValue.serverTimestamp();
    }

    await _appointmentsRef.doc(appointmentId).update(updates);
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _appointmentsRef.doc(appointmentId).delete();
  }

  // Search functionality
  Future<List<Visitor>> searchVisitors(String query) async {
    final snapshot = await _visitorsRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) => Visitor.fromFirestore(doc)).toList();
  }
}
