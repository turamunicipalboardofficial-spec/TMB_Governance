import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../controllers/driver_dashboard_controller.dart';

class DriverMapTab extends GetView<DriverDashboardController> {
  const DriverMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMapCard(),
          const SizedBox(height: 16),
          _buildCurrentLocationCard(),
          const SizedBox(height: 16),
          _buildRouteStopsOverview(),
          const SizedBox(height: 16),
          _buildGpsStatusCard(),
        ],
      ),
    );
  }

  // ── Map Card (Mock Visualization) ─────────────

  Widget _buildMapCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 300,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Grid lines
            CustomPaint(
              size: const Size(double.infinity, 300),
              painter: _GridPainter(),
            ),
            // Stop markers
            Obx(() {
              final data = controller.routeData.value;
              final stops = data?.route?.stops ?? [];
              if (stops.isEmpty) {
                return const Center(
                  child: Text(
                    'No route stops',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  // Stop markers
                  ...stops.asMap().entries.map((entry) {
                    final i = entry.key;
                    final stop = entry.value;
                    final x = 30.0 + (i * (250.0 / stops.length));
                    final y = 80.0 + (i % 3) * 60.0;
                    return Positioned(
                      left: x,
                      top: y,
                      child: _stopMarker(stop),
                    );
                  }).toList(),
                  // Current location marker
                  Obx(() {
                    if (controller.currentLatitude.value != null) {
                      return Positioned(
                        right: 40,
                        bottom: 50,
                        child: _currentLocationMarker(),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              );
            }),
            // Legend
            Positioned(
              bottom: 8,
              left: 8,
              child: Obx(() {
                final data = controller.routeData.value;
                final stops = data?.route?.stops ?? [];
                final completed =
                    stops.where((s) => s.status == 'completed').length;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completed / ${stops.length} stops completed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }),
            ),
            // Action buttons
            Positioned(
              top: 8,
              right: 8,
              child: Column(
                children: [
                  _mapActionButton(
                    icon: Icons.my_location_rounded,
                    label: 'Send Location',
                    onTap: controller.sendManualLocationUpdate,
                  ),
                  const SizedBox(height: 6),
                  _mapActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'Refresh',
                    onTap: controller.loadDriverRoute,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stopMarker(dynamic stop) {
    final color = _statusColor(stop.status);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${stop.sequence}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            stop.name.length > 8
                ? '${stop.name.substring(0, 8)}…'
                : stop.name,
            style: TextStyle(fontSize: 8, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _currentLocationMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.navigation_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'You',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Current Location Card ─────────────────────

  Widget _buildCurrentLocationCard() {
    return Obx(() {
      final lat = controller.currentLatitude.value;
      final lng = controller.currentLongitude.value;
      final speed = controller.currentSpeed.value;
      final heading = controller.currentHeading.value;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.place_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _infoColumn(
                      'Latitude',
                      lat != null ? lat.toStringAsFixed(6) : '--',
                    ),
                  ),
                  Expanded(
                    child: _infoColumn(
                      'Longitude',
                      lng != null ? lng.toStringAsFixed(6) : '--',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _infoColumn(
                      'Speed',
                      '${speed.toStringAsFixed(1)} km/h',
                    ),
                  ),
                  Expanded(
                    child: _infoColumn(
                      'Heading',
                      heading != null
                          ? '${heading.toStringAsFixed(0)}°'
                          : '--',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Route Stops Overview ──────────────────────

  Widget _buildRouteStopsOverview() {
    return Obx(() {
      final data = controller.routeData.value;
      final stops = data?.route?.stops ?? [];

      final completed = stops.where((s) => s.status == 'completed').length;
      final inProgress = stops.where((s) => s.status == 'in_progress').length;
      final pending = stops.where((s) => s.status == 'pending').length;
      final total = stops.length;
      final progress = total > 0 ? completed / total : 0.0;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline_rounded,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Route Progress',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$completed of $total stops completed',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statusCount('Completed', completed, const Color(0xFF2D9A66)),
                  _statusCount('Active', inProgress, const Color(0xFF60A5FA)),
                  _statusCount('Pending', pending, AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _statusCount(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ── GPS Status Card ───────────────────────────

  Widget _buildGpsStatusCard() {
    return Obx(() {
      final isActive = controller.isOnShift;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.satellite_alt_rounded,
                    color: isActive ? AppColors.success : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GPS Tracking',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.successLight
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
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
                                ? AppColors.success
                                : AppColors.disabled,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              _infoRow(
                'Updates Sent',
                '${controller.totalLocationsSent.value}',
              ),
              _infoRow(
                'Last Update',
                controller.lastLocationSentAt.value != null
                    ? _formatTime(controller.lastLocationSentAt.value!)
                    : '--',
              ),
              _infoRow(
                'Update Interval',
                isActive ? 'Every 15 seconds' : '--',
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Helpers ───────────────────────────────────

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF2D9A66);
      case 'in_progress':
        return const Color(0xFF60A5FA);
      case 'skipped':
        return const Color(0xFFD3444D);
      default:
        return AppColors.textSecondary;
    }
  }
}

// ── Grid Painter for Map Background ─────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}