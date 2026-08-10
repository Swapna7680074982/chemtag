import 'package:flutter/material.dart';
import '../models/chemist.dart';
import '../models/stockist.dart';
import '../models/brand.dart';
import '../models/product.dart';
import '../models/dcr_submission.dart';
import '../services/mock_dcr_service.dart';
import '../core/utils/location_helper.dart';

class DcrProvider with ChangeNotifier {
  final MockDcrService _apiService = MockDcrService();

  // Mapped Chemists
  List<Chemist> _mappedChemists = [];
  List<Chemist> _filteredChemists = [];
  Chemist? _selectedChemist;
  String _chemistSearchQuery = '';
  bool _isLoadingChemists = false;

  // Stockists Selection (Multi-select)
  List<Stockist> _availableStockists = [];
  final Set<String> _selectedStockistIds = {};
  bool _isLoadingStockists = false;

  // Brands & Products Catalog
  List<Brand> _brands = [];
  String? _selectedBrandId; // null or 'ALL' means all brands
  List<Product> _allProductsForStockists = [];
  List<Product> _filteredProducts = [];
  String _productSearchQuery = '';
  bool _isLoadingProducts = false;

  // Product Quantity Entry Map: productId -> quantity
  final Map<String, int> _productQuantities = {};

  // Location & Submission State
  LocationDataResult? _currentLocation;
  bool _isCapturingLocation = false;
  bool _isSubmitting = false;

  // DCR History
  List<DcrSubmission> _dcrHistory = [];
  bool _isLoadingHistory = false;

  // Getters
  List<Chemist> get chemists => _filteredChemists;
  Chemist? get selectedChemist => _selectedChemist;
  bool get isLoadingChemists => _isLoadingChemists;
  String get chemistSearchQuery => _chemistSearchQuery;

  List<Stockist> get availableStockists => _availableStockists;
  Set<String> get selectedStockistIds => _selectedStockistIds;
  List<Stockist> get selectedStockistsList => _availableStockists
      .where((s) => _selectedStockistIds.contains(s.id))
      .toList();
  bool get isLoadingStockists => _isLoadingStockists;

  List<Brand> get brands => _brands;
  String? get selectedBrandId => _selectedBrandId;
  List<Product> get products => _filteredProducts;
  String get productSearchQuery => _productSearchQuery;
  bool get isLoadingProducts => _isLoadingProducts;

  Map<String, int> get productQuantities => _productQuantities;

  LocationDataResult? get currentLocation => _currentLocation;
  bool get isCapturingLocation => _isCapturingLocation;
  bool get isSubmitting => _isSubmitting;

  List<DcrSubmission> get dcrHistory => _dcrHistory;
  bool get isLoadingHistory => _isLoadingHistory;

  // Calculations
  int get totalItemsCount =>
      _productQuantities.values.where((qty) => qty > 0).length;

  int get totalUnitsQuantity =>
      _productQuantities.values.fold(0, (sum, qty) => sum + qty);

  double get totalEstimatedValue {
    double total = 0.0;
    _productQuantities.forEach((productId, qty) {
      if (qty > 0) {
        final product = _allProductsForStockists.firstWhere(
          (p) => p.id == productId,
          orElse: () => Product(
            id: '',
            name: '',
            skuCode: '',
            brandId: '',
            brandName: '',
            packSize: '',
            ptr: 0.0,
            mrp: 0.0,
            availableStockistIds: [],
          ),
        );
        total += product.ptr * qty;
      }
    });
    return total;
  }

  DcrProvider() {
    _initBrands();
  }

  Future<void> _initBrands() async {
    _brands = await _apiService.getBrands();
    notifyListeners();
  }

  // --- Step 1: Mapped Chemists ---
  Future<void> loadMappedChemists(String tseEmployeeId) async {
    _isLoadingChemists = true;
    notifyListeners();

    _mappedChemists = await _apiService.getMappedChemists(tseEmployeeId);
    _applyChemistFilter();
    _isLoadingChemists = false;
    notifyListeners();
  }

  void filterChemists(String query) {
    _chemistSearchQuery = query;
    _applyChemistFilter();
    notifyListeners();
  }

  void _applyChemistFilter() {
    if (_chemistSearchQuery.trim().isEmpty) {
      _filteredChemists = List.from(_mappedChemists);
    } else {
      final q = _chemistSearchQuery.toLowerCase();
      _filteredChemists = _mappedChemists.where((c) {
        return c.storeName.toLowerCase().contains(q) ||
            c.ownerName.toLowerCase().contains(q) ||
            c.locality.toLowerCase().contains(q) ||
            c.licenseNo.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<void> selectChemist(Chemist chemist) async {
    _selectedChemist = chemist;
    _selectedStockistIds.clear();
    _productQuantities.clear();
    _selectedBrandId = null;
    _productSearchQuery = '';
    notifyListeners();

    // Fetch mapped stockists for this chemist
    _isLoadingStockists = true;
    notifyListeners();

    _availableStockists =
        await _apiService.getStockistsForChemist(chemist.mappedStockistIds);

    // Do not auto-select first stockist by default per user requirement
    await loadProductsForSelectedStockists();

    _isLoadingStockists = false;
    notifyListeners();
  }

  // --- Step 2: Multi-Stockist Selection ---
  void toggleStockist(String stockistId) {
    if (_selectedStockistIds.contains(stockistId)) {
      _selectedStockistIds.remove(stockistId);
    } else {
      _selectedStockistIds.add(stockistId);
    }
    loadProductsForSelectedStockists();
    notifyListeners();
  }

  Future<void> loadProductsForSelectedStockists() async {
    _isLoadingProducts = true;
    notifyListeners();

    _allProductsForStockists = await _apiService
        .getProductsForStockists(_selectedStockistIds.toList());
    _applyProductFilter();

    _isLoadingProducts = false;
    notifyListeners();
  }

  // --- Step 3: Brand & Product Filter & Quantities ---
  void setBrandFilter(String? brandId) {
    if (brandId == 'ALL') {
      _selectedBrandId = null;
    } else {
      _selectedBrandId = brandId;
    }
    _applyProductFilter();
    notifyListeners();
  }

  void filterProducts(String query) {
    _productSearchQuery = query;
    _applyProductFilter();
    notifyListeners();
  }

  void _applyProductFilter() {
    _filteredProducts = _allProductsForStockists.where((p) {
      bool matchesBrand = (_selectedBrandId == null || _selectedBrandId == 'ALL') ||
          p.brandId == _selectedBrandId;
      bool matchesSearch = _productSearchQuery.trim().isEmpty ||
          p.name.toLowerCase().contains(_productSearchQuery.toLowerCase()) ||
          p.skuCode.toLowerCase().contains(_productSearchQuery.toLowerCase()) ||
          p.brandName.toLowerCase().contains(_productSearchQuery.toLowerCase());
      return matchesBrand && matchesSearch;
    }).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _productQuantities.remove(productId);
    } else {
      _productQuantities[productId] = quantity;
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    int current = _productQuantities[productId] ?? 0;
    _productQuantities[productId] = current + 1;
    notifyListeners();
  }

  void decrementQuantity(String productId) {
    int current = _productQuantities[productId] ?? 0;
    if (current > 1) {
      _productQuantities[productId] = current - 1;
    } else {
      _productQuantities.remove(productId);
    }
    notifyListeners();
  }

  int getQuantity(String productId) => _productQuantities[productId] ?? 0;

  // --- Step 4: Geo-Location Capture & DCR Submission ---
  Future<LocationDataResult> captureLocation() async {
    _isCapturingLocation = true;
    notifyListeners();

    _currentLocation = await LocationHelper.getCurrentLocation();

    _isCapturingLocation = false;
    notifyListeners();
    return _currentLocation!;
  }

  Future<bool> submitDcr({
    required String tseEmployeeId,
    required String tseName,
    String notes = '',
  }) async {
    if (_selectedChemist == null || _selectedStockistIds.isEmpty) return false;

    _isSubmitting = true;
    notifyListeners();

    // Ensure GPS position is captured
    if (_currentLocation == null) {
      await captureLocation();
    }

    // Enforce mandatory valid location (no error messages allowed for submission)
    if (_currentLocation == null || _currentLocation!.errorMessage != null) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }

    final items = <DcrItem>[];
    _productQuantities.forEach((productId, qty) {
      if (qty > 0) {
        final product = _allProductsForStockists.firstWhere((p) => p.id == productId);
        items.add(DcrItem(
          productId: product.id,
          productName: product.name,
          brandName: product.brandName,
          packSize: product.packSize,
          quantity: qty,
          ptr: product.ptr,
        ));
      }
    });

    final submission = DcrSubmission(
      id: 'DCR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      tseEmployeeId: tseEmployeeId,
      tseName: tseName,
      chemist: _selectedChemist!,
      selectedStockists: selectedStockistsList,
      items: items,
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      accuracyMeters: _currentLocation!.accuracyMeters,
      submittedAt: DateTime.now(),
      notes: notes,
    );

    bool success = await _apiService.submitDcrReport(submission);

    if (success) {
      _dcrHistory.insert(0, submission);
      clearQuantities();
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  void clearQuantities() {
    _productQuantities.clear();
    _currentLocation = null;
    notifyListeners();
  }

  Future<void> fetchDcrHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    _dcrHistory = await _apiService.getDcrHistory();

    _isLoadingHistory = false;
    notifyListeners();
  }

  void resetWorkflow() {
    _selectedChemist = null;
    _selectedStockistIds.clear();
    _availableStockists.clear();
    _allProductsForStockists.clear();
    _filteredProducts.clear();
    _productQuantities.clear();
    _selectedBrandId = null;
    _productSearchQuery = '';
    _currentLocation = null;
    notifyListeners();
  }
}
