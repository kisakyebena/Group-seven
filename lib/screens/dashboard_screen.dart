import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/visitor_service.dart';
import '../widgets/custom_drawer.dart';
import 'register_visitor_screen.dart';
import 'view_visitors_screen.dart';
import 'schedule_appointment_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VisitorService _visitorService = VisitorService();
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    final stats = await _visitorService.getVisitorStats();
    setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
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
              child: const Icon(Icons.menu_rounded, color: Color(0xFF0D3B66)),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: Color(0xFF0D3B66)),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadStats();
        },
        color: theme.colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.userEmail?.split('@')[0] ?? 'Staff',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_alt_outlined,
                        title: 'Total Visitors',
                        value: _stats?['total']?.toString() ?? '0',
                        color: const Color(0xFF4A90E2),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.today_outlined,
                        title: 'Today',
                        value: _stats?['today']?.toString() ?? '0',
                        color: const Color(0xFF2ECC71),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.login_outlined,
                        title: 'Checked In',
                        value: _stats?['checkedIn']?.toString() ?? '0',
                        color: const Color(0xFFF39C12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_month_outlined,
                        title: 'This Month',
                        value: _stats?['thisMonth']?.toString() ?? '0',
                        color: const Color(0xFF9B59B6),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildQuickAction(
                      icon: Icons.person_add_rounded,
                      title: 'Register\nVisitor',
                      color: const Color(0xFF4A90E2),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterVisitorScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      icon: Icons.search_rounded,
                      title: 'Search\nVisitor',
                      color: const Color(0xFF2ECC71),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewVisitorsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      icon: Icons.calendar_today_rounded,
                      title: 'Schedule\nVisit',
                      color: const Color(0xFFF39C12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScheduleAppointmentScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      icon: Icons.assessment_rounded,
                      title: 'Generate\nReport',
                      color: const Color(0xFF9B59B6),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Recent Visitors
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Visitors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewVisitorsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildRecentVisitorsList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentVisitorsList() {
    return StreamBuilder<List>(
      stream: _visitorService.getVisitorsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No visitors yet',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final visitors = snapshot.data!.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: visitors.length,
          itemBuilder: (context, index) {
            final visitor = visitors[index];
            return _buildVisitorTile(visitor);
          },
        );
      },
    );
  }

  Widget _buildVisitorTile(dynamic visitor) {
    final isCheckedIn = visitor.status == 'checked_in';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isCheckedIn ? const Color(0xFF2ECC71) : Colors.grey.shade400,
                isCheckedIn ? const Color(0xFF27AE60) : Colors.grey.shade500,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            isCheckedIn ? Icons.person : Icons.person_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          visitor.name ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              DateFormat('HH:mm').format(visitor.timeIn),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isCheckedIn
                    ? const Color(0xFF2ECC71).withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isCheckedIn ? 'Active' : 'Completed',
                style: TextStyle(
                  color: isCheckedIn ? const Color(0xFF2ECC71) : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ),
    );
  }
}
