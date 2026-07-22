import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/error/failure.dart';
import '../models/billing_models.dart';
import '../repositories/billing_admin_repository.dart';

class BillingAdminController extends GetxController {
  final BillingAdminRepository _repository;

  BillingAdminController(this._repository);

  // Markets
  final markets = <MarketModel>[].obs;
  final isLoadingMarkets = false.obs;

  // Shop lookup (dashboard search: market + shop no -> bills/outstanding)
  final selectedMarket = Rxn<MarketModel>();
  final shopNoCtrl = TextEditingController();
  final isLoadingShopBills = false.obs;
  final shopBills = Rxn<ShopBillsResult>();
  final outstanding = Rxn<OutstandingResult>();

  // Generate bills (manual rows)
  final generateBillMonthCtrl = TextEditingController();
  final billRows = <BillRowInput>[].obs;
  final isGenerating = false.obs;
  final generateResult = Rxn<GenerateBillsResult>();

  // Generate bills (file upload)
  final uploadBillMonthCtrl = TextEditingController();
  final uploadSheetNameCtrl = TextEditingController();
  final pickedFileName = ''.obs;
  final pickedFilePath = ''.obs;
  final isUploading = false.obs;
  final uploadResult = Rxn<GenerateBillsResult>();

  // Update payment status
  final isUpdatingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMarkets();
    addBillRow();
  }

  Future<void> fetchMarkets() async {
    isLoadingMarkets.value = true;
    try {
      final result = await _repository.getMarkets();
      markets.assignAll(result);
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      debugPrint('❌ fetchMarkets error: $e');
      CustomSnackbar.showError('Failed to load markets');
    } finally {
      isLoadingMarkets.value = false;
    }
  }

  // ─── Shop lookup ──────────────────────────────────────────────────────────

  Future<void> lookupShop() async {
    final market = selectedMarket.value;
    final shopNo = shopNoCtrl.text.trim();
    if (market == null || shopNo.isEmpty) {
      CustomSnackbar.showWarning('Select a market and enter a shop number');
      return;
    }

    isLoadingShopBills.value = true;
    shopBills.value = null;
    outstanding.value = null;
    try {
      final bills = await _repository.getShopBills(market.marketId, shopNo);
      final due = await _repository.getOutstanding(market.marketId, shopNo);
      shopBills.value = bills;
      outstanding.value = due;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      debugPrint('❌ lookupShop error: $e');
      CustomSnackbar.showError('Failed to load shop billing details');
    } finally {
      isLoadingShopBills.value = false;
    }
  }

  void clearShopLookup() {
    selectedMarket.value = null;
    shopNoCtrl.clear();
    shopBills.value = null;
    outstanding.value = null;
  }

  // ─── Generate bills (manual) ─────────────────────────────────────────────

  void addBillRow() {
    billRows.add(BillRowInput());
  }

  void removeBillRow(int index) {
    if (billRows.length <= 1) return;
    billRows.removeAt(index);
  }

  Future<void> submitGenerateBills() async {
    final billMonth = generateBillMonthCtrl.text.trim();
    if (billMonth.isEmpty) {
      CustomSnackbar.showWarning('Select a bill month');
      return;
    }
    final validRows = billRows
        .where((r) => r.marketId.isNotEmpty && r.shopNo.isNotEmpty)
        .toList();
    if (validRows.isEmpty) {
      CustomSnackbar.showWarning('Add at least one shop with market and shop number');
      return;
    }

    isGenerating.value = true;
    generateResult.value = null;
    try {
      final result = await _repository.generateMonthlyBills(
        billMonth: billMonth,
        bills: validRows,
      );
      generateResult.value = result;
      CustomSnackbar.showSuccess('${result.generatedCount} bill(s) generated successfully');
      billRows.assignAll([BillRowInput()]);
      generateBillMonthCtrl.clear();
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to generate bills');
    } finally {
      isGenerating.value = false;
    }
  }

  // ─── Generate bills (file upload) ────────────────────────────────────────

  void setPickedFile(String path, String name) {
    pickedFilePath.value = path;
    pickedFileName.value = name;
  }

  void clearPickedFile() {
    pickedFilePath.value = '';
    pickedFileName.value = '';
  }

  Future<void> submitUploadBillingSheet() async {
    final billMonth = uploadBillMonthCtrl.text.trim();
    if (billMonth.isEmpty) {
      CustomSnackbar.showWarning('Select a bill month');
      return;
    }
    if (pickedFilePath.value.isEmpty) {
      CustomSnackbar.showWarning('Choose an XLSX or CSV file to upload');
      return;
    }

    isUploading.value = true;
    uploadResult.value = null;
    try {
      final result = await _repository.uploadMonthlyBillingSheet(
        billMonth: billMonth,
        filePath: pickedFilePath.value,
        fileName: pickedFileName.value,
        sheetName: uploadSheetNameCtrl.text.trim().isEmpty
            ? null
            : uploadSheetNameCtrl.text.trim(),
      );
      uploadResult.value = result;
      CustomSnackbar.showSuccess('${result.generatedCount} bill(s) generated from upload');
      clearPickedFile();
      uploadBillMonthCtrl.clear();
      uploadSheetNameCtrl.clear();
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
    } catch (e) {
      CustomSnackbar.showError('Failed to process billing sheet');
    } finally {
      isUploading.value = false;
    }
  }

  // ─── Update payment status ───────────────────────────────────────────────

  Future<bool> updatePaymentStatus({
    required int billId,
    int? paymentDetailId,
    String? orderId,
    String? paymentId,
    double? amount,
    required String status,
    String? paymentRemarks,
  }) async {
    isUpdatingPayment.value = true;
    try {
      final result = await _repository.updatePaymentStatus(
        billId: billId,
        paymentDetailId: paymentDetailId,
        orderId: orderId,
        paymentId: paymentId,
        amount: amount,
        status: status,
        paymentRemarks: paymentRemarks,
      );
      CustomSnackbar.showSuccess(result.message);

      // Refresh the shop lookup if it's currently showing this bill's shop
      final currentShop = shopBills.value;
      if (currentShop != null &&
          currentShop.marketId == result.bill.marketId &&
          currentShop.shopNo == result.bill.shopNo) {
        await lookupShop();
      }
      return true;
    } on Failure catch (f) {
      CustomSnackbar.showError(f.message);
      return false;
    } catch (e) {
      CustomSnackbar.showError('Failed to update payment status');
      return false;
    } finally {
      isUpdatingPayment.value = false;
    }
  }

  @override
  void onClose() {
    shopNoCtrl.dispose();
    generateBillMonthCtrl.dispose();
    uploadBillMonthCtrl.dispose();
    uploadSheetNameCtrl.dispose();
    super.onClose();
  }
}
