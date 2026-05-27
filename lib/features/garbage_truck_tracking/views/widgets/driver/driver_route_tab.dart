import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../controllers/driver_dashboard_controller.dart';

class DriverRouteTab extends GetView<DriverDashboardController> {
  const DriverRouteTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.routeState.value) {
        case DriverRouteState.loading:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading route...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        case DriverRouteState.error:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  'Failed to load route',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadDriverRoute,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        case DriverRouteState.loaded:
          return _buildRouteContent();
        default:
          return Center(
            child: Text(
              'No route data available',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
      }
    });
  }

  Widget _buildRouteContent() {
    final data = controller.routeData.value;
    if (data == null) return const SizedBox.shrink();

    final route = data.route;
    final stops = route?.stops ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Route Header Card ─────────────────
          _buildRouteHeaderCard(route),
          const SizedBox(height: 16),
          // ── Route Stops List ──────────────────
          if (stops.isEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.route_rounded,
                        size: 40, color: AppColors.textTertiary),
                    const SizedBox(height: 8),
                    Text(
                      'No stops assigned',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildStopsList(stops),
          const SizedBox(height: 16),
          // ── Tips Card ─────────────────────────
          _buildTipsCard(),
        ],
      ),
    );
  }

  Widget _buildRouteHeaderCard(dynamic route) {
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentExtraLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route?.routeName ?? 'Unknown Route',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${(route?.stops ?? []).length} stops',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _statItem(
                  Icons.timer_outlined,
                  '${route?.estimatedDurationMinutes ?? 0} min',
                  'Duration',
                ),
                const SizedBox(width: 24),
                _statItem(
                  Icons.straighten_rounded,
                  '${(route?.distanceKm ?? 0).toStringAsFixed(1)} km',
                  'Distance',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStopsList(List stops) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Stops',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(height: 20),
            ...stops.map((stop) => _buildStopItem(stop)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStopItem(dynamic stop) {
    final color = _statusColor(stop.status);
    final icon = _statusIcon(stop.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sequence circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Center(
              child: Text(
                '${stop.sequence}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Stop details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${stop.latitude.toStringAsFixed(4)}, ${stop.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  _statusLabel(stop.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 1,
      color: AppColors.accentExtraLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tips',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _tipItem('Follow stops in sequence order'),
            _tipItem('Start your shift before departing'),
            _tipItem('GPS tracking updates every 15 seconds'),
            _tipItem('Use the Map tab to send manual location'),
          ],
        ),
      ),
    );
  }

  Widget _tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: TextStyle(color: AppColors.accent, fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_rounded;
      case 'in_progress':
        return Icons.directions_run_rounded;
      case 'skipped':
        return Icons.skip_next_rounded;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Done';
      case 'in_progress':
        return 'Active';
      case 'skipped':
        return 'Skipped';
      default:
        return 'Pending';
    }
  }
}