import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/service_request_provider.dart';

class ServiceRequestScreen extends ConsumerStatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  ConsumerState<ServiceRequestScreen> createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends ConsumerState<ServiceRequestScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data
    Future.microtask(
      () => ref.read(serviceRequestProvider.notifier).fetchRequests(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guest = ref.watch(authProvider).guest;
    final requestState = ref.watch(serviceRequestProvider);

    // Security Check
    if (guest == null || !guest.isCheckedIn) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: Text("Access Denied", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Services Request'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.read(serviceRequestProvider.notifier).fetchRequests(),
        color: AppTheme.goldPrimary,
        backgroundColor: AppTheme.surfaceDark,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How can we assist you today?",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.goldPrimary,
                          ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 2x3 Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildLuxuryCard(Icons.bed, 'Room Cleaning'),
                  _buildLuxuryCard(Icons.iron, 'Laundry Service'),
                  _buildLuxuryCard(Icons.room_service, 'Room Service'),
                  _buildLuxuryCard(Icons.build, 'Maintenance'),
                  _buildLuxuryCard(Icons.alarm, 'Wake-up Call'),
                  _buildLuxuryCard(Icons.card_giftcard, 'Extra Amenities'),
                ],
              ),
            ),

            // Active Requests Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withOpacity(0.1),
                        border: Border(
                          left: BorderSide(
                            color: AppTheme.goldPrimary,
                            width: 4,
                          ),
                        ),
                      ),
                      child: const Text(
                        "My Active Requests",
                        style: TextStyle(
                          color: AppTheme.goldPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Requests List or Empty State
            if (requestState.isLoading && requestState.requests.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.goldPrimary),
                ),
              )
            else if (requestState.requests.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      "No active requests.",
                      style: TextStyle(color: Colors.white30),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final req = requestState.requests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRequestItem(req),
                    );
                  }, childCount: requestState.requests.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildLuxuryCard(IconData icon, String label) {
    return InkWell(
      onTap: () => _showRequestModal(context, label, icon),
      borderRadius: BorderRadius.circular(24),
      splashColor: AppTheme.goldPrimary.withOpacity(0.3),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 24,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            AppTheme.goldPrimary.withOpacity(0.5),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.goldPrimary, size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(ServiceRequest req) {
    Color statusColor = Colors.grey;
    if (req.status == 'In Progress') statusColor = Colors.blue;
    if (req.status == 'Completed') statusColor = Colors.green;
    if (req.status == 'Cancelled') statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.goldPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForType(req.type),
              color: AppTheme.goldPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('hh:mm a').format(req.createdAt),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChip(req.priority, _getPriorityColor(req.priority)),
              const SizedBox(height: 4),
              Text(
                req.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.contains('Room Cleaning')) return Icons.bed;
    if (type.contains('Laundry')) return Icons.iron;
    if (type.contains('Room Service')) return Icons.room_service;
    if (type.contains('Maintenance')) return Icons.build;
    if (type.contains('Wake-up')) return Icons.alarm;
    if (type.contains('Extra Amenities')) return Icons.card_giftcard;
    return Icons.room_service; // Default
  }

  Color _getPriorityColor(String p) {
    if (p == 'High') return Colors.orange;
    if (p == 'Urgent') return Colors.red;
    return Colors.grey;
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showRequestModal(BuildContext context, String title, IconData icon) {
    final messageController = TextEditingController();
    String selectedPriority = 'Normal';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(color: AppTheme.goldPrimary, width: 1),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Icon(icon, size: 60, color: AppTheme.goldPrimary),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.goldPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Priority Selection
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Priority Level",
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['Normal', 'High', 'Urgent'].map((p) {
                      final isSelected = selectedPriority == p;
                      Color baseColor = _getPriorityColor(p);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () => setState(() => selectedPriority = p),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? baseColor
                                    : Colors.transparent,
                                border: Border.all(color: baseColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  p,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : baseColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Message Input
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Please describe your request...",
                      hintStyle: const TextStyle(color: Colors.white30),
                      fillColor: const Color(0xFF1E293B),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppTheme.goldPrimary,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await ref
                            .read(serviceRequestProvider.notifier)
                            .createRequest(
                              title,
                              messageController.text,
                              selectedPriority,
                            );
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Request submitted successfully!",
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: AppTheme.goldPrimary,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Submit Request",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
