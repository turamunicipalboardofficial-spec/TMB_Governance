import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/atoms/status_badge.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/organisms/empty_state.dart';
import '../../../core/models/ward_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/garbage_admin_controller.dart';
import '../models/garbage_models.dart';

class GarbageDashboardScreen extends GetView<GarbageAdminController> {
  const GarbageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Garbage Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            controller.fetchDashboard(),
            controller.fetchTrucks(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActions(),
              const SizedBox(height: AppSizes.paddingXL),
              _buildFleetSummary(),
              const SizedBox(height: AppSizes.paddingXL),
              _buildFilters(),
              const SizedBox(height: AppSizes.paddingM),
              _buildTruckList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.add_circle_outline,
            label: 'Add Truck',
            color: AppColors.primary,
            onTap: () {
              controller.startAddTruck();
              Get.toNamed(AppRoutes.addTruck);
            },
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: _ActionCard(
            icon: Icons.person_add_alt_outlined,
            label: 'Assign Driver',
            color: AppColors.info,
            onTap: () {
              controller.prepareAssignDriver();
              Get.toNamed(AppRoutes.assignDriver);
            },
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: _ActionCard(
            icon: Icons.schedule_outlined,
            label: 'Schedule',
            color: AppColors.success,
            onTap: () {
              controller.prepareCreateSchedule();
              Get.toNamed(AppRoutes.createSchedule);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFleetSummary() {
    return Obx(() {
      if (controller.isLoadingDashboard.value && controller.dashboard.value == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingXL),
            child: CircularProgressIndicator(),
          ),
        );
      }
      final dash = controller.dashboard.value;
      if (dash == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fleet Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              _StatChip(label: 'Total Trucks', value: '${dash.fleetSummary.totalTrucks}', color: AppColors.primary),
              const SizedBox(width: AppSizes.paddingS),
              _StatChip(label: 'On Route Now', value: '${dash.fleetSummary.onRouteNow}', color: AppColors.success),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            children: [
              _StatChip(label: 'In Maintenance', value: '${dash.fleetSummary.inMaintenance}', color: AppColors.warning),
              const SizedBox(width: AppSizes.paddingS),
              _StatChip(label: 'Drivers On Duty', value: '${dash.driverSummary.onDutyNow}/${dash.driverSummary.totalDrivers}', color: AppColors.info),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.today_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.paddingS),
                Text(
                  '${dash.todayScheduledCollections} collection(s) scheduled today',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trucks',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSizes.paddingM),
        TextField(
          onChanged: controller.onTruckSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search by truck number or plate',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: Obx(() => InlineDropdownField<WardModel>(
                    value: controller.wards.firstWhereOrNull((w) => w.id == controller.truckWardFilter.value),
                    items: controller.wards,
                    placeholder: 'All Wards',
                    itemLabel: (w) => w.wardName,
                    isLoading: controller.isLoadingWards.value,
                    onChanged: (w) => controller.filterTrucksByWard(w?.id),
                  )),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Obx(() => InlineDropdownField<String>(
                    value: controller.truckStatusFilter.value.isEmpty ? null : controller.truckStatusFilter.value,
                    items: kTruckStatuses,
                    placeholder: 'All Statuses',
                    itemLabel: (s) => s[0].toUpperCase() + s.substring(1),
                    onChanged: controller.filterTrucksByStatus,
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTruckList() {
    return Obx(() {
      if (controller.isLoadingTrucks.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingXL),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (controller.trucks.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.paddingXL),
          child: EmptyState(
            icon: Icons.local_shipping_outlined,
            title: 'No Trucks Found',
            message: 'Add a truck to the fleet to get started.',
          ),
        );
      }
      return Column(
        children: controller.trucks.map((t) => _buildTruckCard(t)).toList(),
      );
    });
  }

  Widget _buildTruckCard(GarbageTruckModel truck) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: () {
          controller.startEditTruck(truck);
          Get.toNamed(AppRoutes.addTruck);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(truck.truckNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text(truck.plateNumber, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  StatusBadge(status: truck.status),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  _MiniInfo(icon: Icons.category_outlined, label: truck.truckType.replaceAll('_', ' ')),
                  const SizedBox(width: AppSizes.paddingM),
                  _MiniInfo(icon: Icons.location_city_outlined, label: truck.wardName ?? 'Ward ${truck.wardId}'),
                ],
              ),
              const SizedBox(height: AppSizes.paddingXS),
              Row(
                children: [
                  Icon(
                    truck.hasDriver ? Icons.person : Icons.person_off_outlined,
                    size: 14,
                    color: truck.hasDriver ? AppColors.success : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    truck.hasDriver ? truck.driver!.name : 'No driver assigned',
                    style: TextStyle(
                      fontSize: 12,
                      color: truck.hasDriver ? AppColors.textSecondary : AppColors.textTertiary,
                    ),
                  ),
                  if (truck.isOnRoute) ...[
                    const SizedBox(width: AppSizes.paddingS),
                    const Icon(Icons.circle, size: 8, color: AppColors.success),
                    const SizedBox(width: 4),
                    const Text('On route', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSizes.radiusS)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS, horizontal: AppSizes.paddingS),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppSizes.radiusS)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color), overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
