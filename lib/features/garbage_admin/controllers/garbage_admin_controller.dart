import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/error/failure.dart';
import '../../../core/models/ward_model.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../models/garbage_models.dart';
import '../repositories/garbage_admin_repository.dart';

const List<String> kTruckTypes = ['compactor', 'dumper', 'side_loader', 'roll_off'];
const List<String> kTruckStatuses = ['active', 'maintenance', 'retired', 'breakdown'];
const List<String> kDaysOfWeek = [
  'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
];
const List<String> kCollectionTypes = ['regular', 'bulk', 'recycling', 'special'];

class GarbageAdminController extends GetxController {
  final GarbageAdminRepository _repository;

  GarbageAdminController(this._repository);

  // ─── Dashboard ────────────────────────────────────────────────────
  final isLoadingDashboard = false.obs;
  final dashboard = Rxn<FleetDashboardModel>();

  // ─── Truck list ───────────────────────────────────────────────────
  final trucks = <GarbageTruckModel>[].obs;
  final isLoadingTrucks = false.obs;
  final isPaginatingTrucks = false.obs;
  final truckCurrentPage = 1.obs;
  final truckTotal = 0.obs;
  final truckStatusFilter = ''.obs;
  final truckWardFilter = RxnInt();
  final truckSearchQuery = ''.obs;

  // ─── Wards (shared) ───────────────────────────────────────────────
  final wards = <WardModel>[].obs;
  final isLoadingWards = false.obs;

  // ─── Drivers ──────────────────────────────────────────────────────
  final drivers = <DriverProfileModel>[].obs;
  final isLoadingDrivers = false.obs;

  // ─── Add / edit truck form ────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final truckNumberCtrl = TextEditingController();
  final plateNumberCtrl = TextEditingController();
  final capacityTonsCtrl = TextEditingController();
  final selectedTruckType = RxnString();
  final selectedTruckStatus = 'active'.obs;
  final selectedFormWardId = RxnInt();
  final isSavingTruck = false.obs;
  int? _editingTruckId;

  // ─── Assign driver form ───────────────────────────────────────────
  final selectedAssignDriverUserId = RxnInt();
  final selectedAssignTruckId = RxnInt();
  final isAssigningDriver = false.obs;

  // ─── Create schedule form ─────────────────────────────────────────
  final selectedScheduleWardId = RxnInt();
  final selectedScheduleTruckId = RxnInt();
  final selectedDayOfWeek = RxnString();
  final selectedCollectionType = 'regular'.obs;
  final scheduleStartTimeCtrl = TextEditingController();
  final scheduleEndTimeCtrl = TextEditingController();
  final isCreatingSchedule = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
    fetchWards();
    fetchTrucks();
  }

  Future<void> fetchWards() async {
    isLoadingWards.value = true;
    try {
      final response = await NetworkService.to.get(ApiEndpoints.wardList);
      final data = response.data['ward'] as List? ?? response.data['data'] as List?;
      if (data != null) {
        wards.assignAll(data.map((e) => WardModel.fromJson(e)).toList());
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch wards: $e');
    } finally {
      isLoadingWards.value = false;
    }
  }

  Future<void> fetchDashboard() async {
    isLoadingDashboard.value = true;
    try {
      final result = await _repository.getDashboard();
      dashboard.value = result;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load fleet dashboard');
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  Future<void> fetchTrucks() async {
    isLoadingTrucks.value = true;
    truckCurrentPage.value = 1;
    try {
      final result = await _repository.listTrucks(
        wardId: truckWardFilter.value,
        status: truckStatusFilter.value.isEmpty ? null : truckStatusFilter.value,
        search: truckSearchQuery.value.isEmpty ? null : truckSearchQuery.value,
        page: 1,
      );
      trucks.assignAll(result.trucks);
      truckTotal.value = result.total;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load trucks');
    } finally {
      isLoadingTrucks.value = false;
    }
  }

  Future<void> loadMoreTrucks() async {
    if (isPaginatingTrucks.value || trucks.length >= truckTotal.value) return;
    isPaginatingTrucks.value = true;
    try {
      truckCurrentPage.value++;
      final result = await _repository.listTrucks(
        wardId: truckWardFilter.value,
        status: truckStatusFilter.value.isEmpty ? null : truckStatusFilter.value,
        search: truckSearchQuery.value.isEmpty ? null : truckSearchQuery.value,
        page: truckCurrentPage.value,
      );
      trucks.addAll(result.trucks);
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load more trucks');
    } finally {
      isPaginatingTrucks.value = false;
    }
  }

  void filterTrucksByStatus(String? status) {
    truckStatusFilter.value = status ?? '';
    fetchTrucks();
  }

  void filterTrucksByWard(int? wardId) {
    truckWardFilter.value = wardId;
    fetchTrucks();
  }

  void onTruckSearchChanged(String query) {
    truckSearchQuery.value = query;
    fetchTrucks();
  }

  Future<void> fetchDrivers() async {
    isLoadingDrivers.value = true;
    try {
      final result = await _repository.listDrivers();
      drivers.assignAll(result);
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to load drivers');
    } finally {
      isLoadingDrivers.value = false;
    }
  }

  // ─── Add / edit truck ──────────────────────────────────────────────

  void startAddTruck() {
    _editingTruckId = null;
    truckNumberCtrl.clear();
    plateNumberCtrl.clear();
    capacityTonsCtrl.clear();
    selectedTruckType.value = null;
    selectedTruckStatus.value = 'active';
    selectedFormWardId.value = null;
  }

  void startEditTruck(GarbageTruckModel truck) {
    _editingTruckId = truck.id;
    truckNumberCtrl.text = truck.truckNumber;
    plateNumberCtrl.text = truck.plateNumber;
    capacityTonsCtrl.text = truck.capacityTons?.toString() ?? '';
    selectedTruckType.value = truck.truckType;
    selectedTruckStatus.value = truck.status;
    selectedFormWardId.value = truck.wardId;
  }

  bool get isEditingTruck => _editingTruckId != null;

  Future<void> submitTruckForm() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) return;
    if (selectedTruckType.value == null) {
      CustomSnackbar.showWarning('Select a truck type');
      return;
    }
    if (selectedFormWardId.value == null) {
      CustomSnackbar.showWarning('Select a ward');
      return;
    }
    final capacity = num.tryParse(capacityTonsCtrl.text.trim());
    if (capacity == null) {
      CustomSnackbar.showWarning('Enter a valid capacity');
      return;
    }

    isSavingTruck.value = true;
    try {
      final wasEditing = isEditingTruck;
      if (wasEditing) {
        await _repository.updateTruck(
          id: _editingTruckId!,
          truckNumber: truckNumberCtrl.text.trim(),
          plateNumber: plateNumberCtrl.text.trim(),
          truckType: selectedTruckType.value,
          capacityTons: capacity,
          wardId: selectedFormWardId.value,
          status: selectedTruckStatus.value,
        );
      } else {
        await _repository.addTruck(
          truckNumber: truckNumberCtrl.text.trim(),
          plateNumber: plateNumberCtrl.text.trim(),
          truckType: selectedTruckType.value!,
          capacityTons: capacity,
          wardId: selectedFormWardId.value!,
          status: selectedTruckStatus.value,
        );
      }
      fetchTrucks();
      fetchDashboard();
      Get.back();
      CustomSnackbar.showSuccess(
        wasEditing ? 'Truck updated successfully' : 'Truck added successfully',
      );
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to save truck');
    } finally {
      isSavingTruck.value = false;
    }
  }

  // ─── Assign driver ─────────────────────────────────────────────────

  void prepareAssignDriver() {
    selectedAssignDriverUserId.value = null;
    selectedAssignTruckId.value = null;
    fetchDrivers();
    if (trucks.isEmpty) fetchTrucks();
  }

  Future<void> submitAssignDriver() async {
    final driverUserId = selectedAssignDriverUserId.value;
    final truckId = selectedAssignTruckId.value;
    if (driverUserId == null || truckId == null) {
      CustomSnackbar.showWarning('Select both a driver and a truck');
      return;
    }

    isAssigningDriver.value = true;
    try {
      final result = await _repository.assignDriver(
        driverUserId: driverUserId,
        truckId: truckId,
      );
      fetchDrivers();
      fetchTrucks();
      fetchDashboard();
      Get.back();
      CustomSnackbar.showSuccess(
        '${result.driverName} assigned to ${result.truckNumber}',
      );
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to assign driver');
    } finally {
      isAssigningDriver.value = false;
    }
  }

  // ─── Create schedule ───────────────────────────────────────────────

  void prepareCreateSchedule() {
    selectedScheduleWardId.value = null;
    selectedScheduleTruckId.value = null;
    selectedDayOfWeek.value = null;
    selectedCollectionType.value = 'regular';
    scheduleStartTimeCtrl.clear();
    scheduleEndTimeCtrl.clear();
    if (trucks.isEmpty) fetchTrucks();
  }

  Future<void> submitCreateSchedule() async {
    final wardId = selectedScheduleWardId.value;
    final truckId = selectedScheduleTruckId.value;
    final day = selectedDayOfWeek.value;
    final start = scheduleStartTimeCtrl.text.trim();
    final end = scheduleEndTimeCtrl.text.trim();

    if (wardId == null || truckId == null || day == null || start.isEmpty || end.isEmpty) {
      CustomSnackbar.showWarning('Fill in all required fields');
      return;
    }

    isCreatingSchedule.value = true;
    try {
      await _repository.createSchedule(
        wardId: wardId,
        truckId: truckId,
        dayOfWeek: day,
        startTime: start,
        endTime: end,
        collectionType: selectedCollectionType.value,
      );
      fetchDashboard();
      Get.back();
      CustomSnackbar.showSuccess('Collection schedule created successfully');
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to create schedule');
    } finally {
      isCreatingSchedule.value = false;
    }
  }

  String getWardName(int? wardId) {
    if (wardId == null) return 'N/A';
    final ward = wards.firstWhereOrNull((w) => w.id == wardId);
    return ward?.wardName ?? 'Ward $wardId';
  }

  @override
  void onClose() {
    truckNumberCtrl.dispose();
    plateNumberCtrl.dispose();
    capacityTonsCtrl.dispose();
    scheduleStartTimeCtrl.dispose();
    scheduleEndTimeCtrl.dispose();
    super.onClose();
  }
}
