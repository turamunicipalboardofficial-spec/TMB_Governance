import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../controllers/driver_dashboard_controller.dart';

class DriverShiftTab extends GetView<DriverDashboardController> {
  const DriverShiftTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTruckInfoCard(),
          const SizedBox(height: 16),
          _buildShiftStatusCard(),
          const SizedBox(height: 16),
          _buildLocationStatusCard(),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.shiftState.value == DriverShiftState.ended) {
              return _buildShiftSummaryCard();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // ── Truck Info Card ───────────────────────────

  Widget _buildTruckInfoCard() {
    return Obx(() {
      final route = controller.routeData.value;
      if (route == null) return const SizedBox.shrink();

      final truck = route.truck;
      final schedule = route.schedule;

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
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truck?.truckNumber ?? 'N/A',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (truck?.plateNumber != null)
                          Text(
                            truck!.plateNumber,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (truck?.status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: truck!.status == 'active'
                            ? AppColors.successLight
                            : AppColors.warningLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        truck.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: truck.status == 'active'
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
              if (schedule != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    _infoChip(
                      Icons.calendar_today_rounded,
                      schedule.day.toUpperCase(),
                    ),
                    const SizedBox(width: 12),
                    _infoChip(
                      Icons.access_time_rounded,
                      '${schedule.startTime} - ${schedule.endTime}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _infoChip(
                  Icons.delete_outline_rounded,
                  schedule.collectionType,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ── Shift Status Card ─────────────────────────

  Widget _buildShiftStatusCard() {
    return Obx(() {
      final isActive = controller.isOnShift;
      final isLoading =
          controller.shiftState.value == DriverShiftState.loading;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status indicator
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.textTertiary.withOpacity(0.15),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppColors.success : AppColors.disabled,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.success.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isActive ? 'Shift Active' : 'Shift Inactive',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.success : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              // Duration
              Text(
                controller.shiftDuration,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Duration',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 20),
              // Start / End button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : isActive
                          ? _showEndShiftDialog
                          : controller.startShift,
                  icon: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isActive
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                        ),
                  label: Text(
                    isLoading
                        ? 'Processing...'
                        : isActive
                            ? 'End Shift'
                            : 'Start Shift',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isActive ? AppColors.error : AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Location Status Card ──────────────────────

  Widget _buildLocationStatusCard() {
    return Obx(() {
      final lat = controller.currentLatitude.value;
      final lng = controller.currentLongitude.value;
      final speed = controller.currentSpeed.value;

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
                    Icons.gps_fixed_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GPS Status',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              _infoRow(
                'Latitude',
                lat != null ? lat.toStringAsFixed(6) : '--',
              ),
              _infoRow(
                'Longitude',
                lng != null ? lng.toStringAsFixed(6) : '--',
              ),
              _infoRow('Speed', '${speed.toStringAsFixed(1)} km/h'),
              _infoRow(
                'Last Update',
                controller.lastLocationSentAt.value != null
                    ? _formatTime(controller.lastLocationSentAt.value!)
                    : '--',
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Shift Summary Card ────────────────────────

  Widget _buildShiftSummaryCard() {
    final data = controller.shiftData.value;
    if (data == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      color: AppColors.infoLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize_rounded, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Shift Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: controller.resetShiftState,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
            const Divider(height: 16),
            _infoRow('Started', data.shiftStartedAt ?? '--'),
            _infoRow('Ended', data.shiftEndedAt ?? '--'),
            _infoRow(
              'Locations Reported',
              '${data.totalLocationsReported ?? 0}',
            ),
            _infoRow(
              'Distance',
              '${(data.totalDistanceKm ?? 0).toStringAsFixed(1)} km',
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────

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

  void _showEndShiftDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('End Shift?'),
          ],
        ),
        content: const Text(
          'GPS tracking will stop. Are you sure you want to end your shift?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.endShift();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Shift'),
          ),
        ],
      ),
    );
  }
}