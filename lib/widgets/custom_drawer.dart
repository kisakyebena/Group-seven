import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../screens/register_visitor_screen.dart';
import '../screens/view_visitors_screen.dart';
import '../screens/schedule_appointment_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Uganda Prisons Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mbarara Main Prison',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Menu Items
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.dashboard_rounded,
                        title: 'Dashboard',
                        isSelected: true,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.person_add_rounded,
                        title: 'Register Visitor',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterVisitorScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.people_alt_rounded,
                        title: 'View Visitors',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ViewVisitorsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.calendar_month_rounded,
                        title: 'Appointments',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScheduleAppointmentScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.assessment_rounded,
                        title: 'Reports',
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Reports coming soon'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(indent: 20, endIndent: 20),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        textColor: Colors.red,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    authProvider.logout();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // User Info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary,
                            theme.colorScheme.secondary.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            authProvider.userEmail?.split('@')[0] ?? 'Staff',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: textColor ??
                      (isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade600),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor ??
                          (isSelected
                              ? theme.colorScheme.primary
                              : Colors.grey.shade800),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
