import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/visitor_service.dart';
import '../models/visitor.dart';
import 'visitor_detail_screen.dart';

class ViewVisitorsScreen extends StatefulWidget {
  const ViewVisitorsScreen({super.key});

  @override
  State<ViewVisitorsScreen> createState() => _ViewVisitorsScreenState();
}

class _ViewVisitorsScreenState extends State<ViewVisitorsScreen>
    with SingleTickerProviderStateMixin {
  final VisitorService _visitorService = VisitorService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
            child:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF0D3B66)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search visitors...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              )
            : const Text(
                'Visitor Records',
                style: TextStyle(
                  color: Color(0xFF2D3436),
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
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
              child: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: const Color(0xFF0D3B66),
              ),
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
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
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'All'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVisitorsList('checked_in'),
          _buildVisitorsList('checked_out'),
          _buildVisitorsList(null),
        ],
      ),
    );
  }

  Widget _buildVisitorsList(String? status) {
    return StreamBuilder<List<Visitor>>(
      stream: status != null
          ? _visitorService.getVisitorsStream(status: status)
          : _visitorService.getVisitorsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error loading visitors',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        List<Visitor> visitors = snapshot.data ?? [];

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          visitors = visitors.where((v) {
            return v.name.toLowerCase().contains(_searchQuery) ||
                v.ninNumber.toLowerCase().contains(_searchQuery) ||
                v.personToVisit.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (visitors.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: () async {},
          color: const Color(0xFF0D3B66),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: visitors.length,
            itemBuilder: (context, index) {
              final visitor = visitors[index];
              return _buildVisitorCard(visitor);
            },
          ),
        );
      },
    );
  }

  Widget _buildVisitorCard(Visitor visitor) {
    final isActive = visitor.status == 'checked_in';
    final duration = visitor.visitDuration;
    final hours = duration?.inHours ?? 0;
    final minutes = duration?.inMinutes.remainder(60) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VisitorDetailScreen(visitor: visitor),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Indicator
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
                          : [Colors.grey.shade400, Colors.grey.shade500],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isActive ? Icons.person : Icons.person_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Visitor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Visiting: ${visitor.personToVisit}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.credit_card,
                            label: visitor.ninNumber,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: Icons.location_on,
                            label: visitor.district,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Time & Action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF2ECC71).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Completed',
                        style: TextStyle(
                          color:
                              isActive ? const Color(0xFF2ECC71) : Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isActive)
                      Row(
                        children: [
                          Icon(Icons.timer,
                              size: 14, color: Colors.orange.shade400),
                          const SizedBox(width: 4),
                          Text(
                            '${hours}h ${minutes}m',
                            style: TextStyle(
                              color: Colors.orange.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        DateFormat('HH:mm').format(visitor.timeOut!),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3B66).withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF0D3B66).withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF0D3B66).withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String? status) {
    String message;
    IconData icon;

    switch (status) {
      case 'checked_in':
        message = 'No active visitors';
        icon = Icons.person_off_outlined;
        break;
      case 'checked_out':
        message = 'No completed visits';
        icon = Icons.history;
        break;
      default:
        message = 'No visitors found';
        icon = Icons.people_outline;
    }

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
            child: Icon(icon, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
