import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/visitor_service.dart';
import '../models/appointment.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _visitorService = VisitorService();
  late TabController _tabController;

  final _visitorNameController = TextEditingController();
  final _visitorContactController = TextEditingController();
  final _visitorNinController = TextEditingController();
  final _personToVisitController = TextEditingController();
  final _purposeController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _visitorNameController.dispose();
    _visitorContactController.dispose();
    _visitorNinController.dispose();
    _personToVisitController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0D3B66)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _scheduleAppointment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final appointmentDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final appointment = Appointment(
          visitorName: _visitorNameController.text.trim(),
          visitorContact: _visitorContactController.text.trim(),
          visitorNin: _visitorNinController.text.trim(),
          personToVisit: _personToVisitController.text.trim(),
          appointmentDate: appointmentDateTime,
          purpose: _purposeController.text.trim(),
        );

        await _visitorService.scheduleAppointment(appointment);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Appointment for ${_visitorNameController.text} scheduled',
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2ECC71),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        _clearForm();
        _tabController.animateTo(0);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _visitorNameController.clear();
    _visitorContactController.clear();
    _visitorNinController.clear();
    _personToVisitController.clear();
    _purposeController.clear();
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = const TimeOfDay(hour: 10, minute: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF0D3B66),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Appointments',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: const Color(0xFF0D3B66),
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'New Booking'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAppointmentsList(), _buildBookingForm(theme)],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return StreamBuilder<List<Appointment>>(
      stream: _visitorService.getAppointmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No appointments scheduled',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.add),
                  label: const Text('Schedule New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B66),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return _buildAppointmentCard(appointment);
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isPending = appointment.status == 'pending';
    final isApproved = appointment.status == 'approved';

    Color statusColor;
    String statusText;

    switch (appointment.status) {
      case 'approved':
        statusColor = const Color(0xFF2ECC71);
        statusText = 'Approved';
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFE76F51);
        statusText = 'Cancelled';
        break;
      default:
        statusColor = const Color(0xFFF39C12);
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isPending ? Icons.pending : Icons.check,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            appointment.visitorName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appointment.personToVisit,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat(
                      'MMM dd, yyyy',
                    ).format(appointment.appointmentDate),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm').format(appointment.appointmentDate),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          children: [
            _buildDetailRow('Contact', appointment.visitorContact),
            const SizedBox(height: 8),
            _buildDetailRow('NIN', appointment.visitorNin),
            const SizedBox(height: 8),
            _buildDetailRow('Purpose', appointment.purpose),
            const SizedBox(height: 16),
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _visitorService.updateAppointmentStatus(
                          appointment.id!,
                          'cancelled',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _visitorService.updateAppointmentStatus(
                          appointment.id!,
                          'approved',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D3B66), Color(0xFF1A5C8A)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF0D3B66).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time Selection
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D3B66).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Color(0xFF0D3B66),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Select Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D3B66),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            Text(
              'Visitor Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),

            _buildFormField(
              controller: _visitorNameController,
              label: 'Visitor Name',
              hint: 'Full name',
              icon: Icons.person,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildFormField(
              controller: _visitorContactController,
              label: 'Phone Number',
              hint: 'Contact number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildFormField(
              controller: _visitorNinController,
              label: 'NIN Number',
              hint: 'National ID',
              icon: Icons.credit_card,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildFormField(
              controller: _personToVisitController,
              label: 'Person to Visit',
              hint: 'Inmate name',
              icon: Icons.person_search,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildFormField(
              controller: _purposeController,
              label: 'Purpose',
              hint: 'Reason for visit',
              icon: Icons.info,
              maxLines: 2,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _scheduleAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3B66),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Schedule Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}
