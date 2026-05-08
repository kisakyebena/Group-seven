import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../providers/auth_provider.dart';
import '../services/visitor_service.dart';
import '../widgets/custom_drawer.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  State<ManageAppointmentsScreen> createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen> {
  final VisitorService _visitorService = VisitorService();
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Approved', 'approved'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: _selectedFilter == 'all'
                  ? _visitorService.getAppointmentsStream()
                  : _visitorService.getAppointmentsStream(status: _selectedFilter),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final appointments = snapshot.data!;
                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No appointments found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return _buildAppointmentCard(appointment, isAdmin);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, bool isAdmin) {
    final canApprove = isAdmin || appointment.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.visitorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Visiting: ${appointment.personToVisit}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMM dd, yyyy - HH:mm')
                  .format(appointment.appointmentDate),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            if (appointment.approvedBy != null) ...[
              const SizedBox(height: 4),
              Text(
                'Approved by: ${appointment.approvedBy}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
            if (canApprove && appointment.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _updateStatus(appointment.id!, 'rejected'),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(appointment.id!, 'approved'),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateStatus(String appointmentId, String status) async {
    final authProvider = context.read<AuthProvider>();
    await _visitorService.updateAppointmentStatus(
      appointmentId,
      status,
      approvedBy: authProvider.userName,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment $status')),
    );
  }
}