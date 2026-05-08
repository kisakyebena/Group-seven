import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visitor.dart';
import '../services/visitor_service.dart';

class VisitorDetailScreen extends StatefulWidget {
  final Visitor visitor;

  const VisitorDetailScreen({super.key, required this.visitor});

  @override
  State<VisitorDetailScreen> createState() => _VisitorDetailScreenState();
}

class _VisitorDetailScreenState extends State<VisitorDetailScreen> {
  final VisitorService _visitorService = VisitorService();
  bool _isCheckingOut = false;

  void _checkoutVisitor() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Checkout'),
        content: Text(
          'Checkout ${widget.visitor.name}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE76F51),
            ),
            child: const Text('Checkout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isCheckingOut = true);

      try {
        await _visitorService.checkoutVisitor(widget.visitor.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('${widget.visitor.name} checked out'),
                ],
              ),
              backgroundColor: const Color(0xFF2ECC71),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isCheckingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visitor = widget.visitor;
    final isActive = visitor.status == 'checked_in';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Header with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isActive ? const Color(0xFF0D3B66) : Colors.grey.shade700,
                      isActive ? const Color(0xFF1A5C8A) : Colors.grey.shade600,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          radius: 50,
                          child: Text(
                            visitor.name.isNotEmpty
                                ? visitor.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        visitor.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF2ECC71).withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF2ECC71).withOpacity(0.5)
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? const Color(0xFF2ECC71)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isActive ? 'Checked In' : 'Checked Out',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (isActive)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.print, color: Colors.white),
                  ),
                  onPressed: () {},
                ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duration Card
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF39C12).withOpacity(0.1),
                              const Color(0xFFE67E22).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF39C12).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF39C12),
                                    Color(0xFFE67E22),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Visit Duration',
                                    style: TextStyle(
                                      color: Color(0xFFF39C12),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    visitor.formattedDuration,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3436),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StreamBuilder(
                              stream: Stream.periodic(
                                const Duration(seconds: 1),
                              ),
                              builder: (context, snapshot) {
                                return Text(
                                  DateFormat('HH:mm:ss').format(DateTime.now()),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontFamily: 'monospace',
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    if (isActive) const SizedBox(height: 24),

                    // Personal Info Card
                    _buildInfoCard(
                      title: 'Personal Information',
                      icon: Icons.person,
                      children: [
                        _buildInfoTile(
                          label: 'Full Name',
                          value: visitor.name,
                          icon: Icons.person_outline,
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          label: 'NIN Number',
                          value: visitor.ninNumber,
                          icon: Icons.credit_card,
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          label: 'Contact',
                          value: visitor.contact,
                          icon: Icons.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Visit Info Card
                    _buildInfoCard(
                      title: 'Visit Details',
                      icon: Icons.people,
                      children: [
                        _buildInfoTile(
                          label: 'Visiting',
                          value: visitor.personToVisit,
                          icon: Icons.person_search,
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          label: 'Relationship',
                          value: visitor.relationship,
                          icon: Icons.group,
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          label: 'Purpose',
                          value: visitor.reason,
                          icon: Icons.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location Card
                    _buildInfoCard(
                      title: 'Residence',
                      icon: Icons.location_on,
                      children: [
                        _buildInfoTile(
                          label: 'District',
                          value: visitor.district,
                          icon: Icons.location_city,
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          label: 'Subcounty',
                          value: visitor.subcounty,
                          icon: Icons.map,
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          label: 'Village',
                          value: visitor.village,
                          icon: Icons.home,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Items & Cash Card
                    _buildInfoCard(
                      title: 'Possessions',
                      icon: Icons.inventory,
                      children: [
                        _buildInfoTile(
                          label: 'Items Brought',
                          value: visitor.itemsBrought.isEmpty
                              ? 'None'
                              : visitor.itemsBrought,
                          icon: Icons.inventory_2,
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          label: 'Cash Amount',
                          value:
                              'UGX ${NumberFormat('#,###').format(visitor.cashBrought)}',
                          icon: Icons.attach_money,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Timestamps Card
                    _buildInfoCard(
                      title: 'Timestamps',
                      icon: Icons.access_time,
                      children: [
                        _buildInfoTile(
                          label: 'Check-In',
                          value: DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(visitor.timeIn),
                          icon: Icons.login,
                        ),
                        if (visitor.timeOut != null) ...[
                          _buildDivider(),
                          _buildInfoTile(
                            label: 'Check-Out',
                            value: DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(visitor.timeOut!),
                            icon: Icons.logout,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Checkout Button
                    if (isActive)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isCheckingOut ? null : _checkoutVisitor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE76F51),
                            foregroundColor: Colors.white,
                          ),
                          icon: _isCheckingOut
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
                              : const Icon(Icons.logout),
                          label: Text(
                            _isCheckingOut
                                ? 'Checking Out...'
                                : 'Checkout Visitor',
                            style: const TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B66).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF0D3B66), size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 20,
      endIndent: 20,
    );
  }
}
