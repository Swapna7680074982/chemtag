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
  String? _tseEmployeeId;

  // Page Sizes for Lazy Loading
  static const int _pageSizeChemists = 5;
  static const int _pageSizeStockists = 5;
  static const int _pageSizeProducts = 5;
  static const int _pageSizeHistory = 5;

  // Mapped Chemists
  List<Chemist> _mappedChemists = [];
  List<Chemist> _filteredChemists = [];
  List<Chemist> _paginatedChemists = [];
  Chemist? _selectedChemist;
  String _chemistSearchQuery = '';
  bool _isLoadingChemists = false;
  bool _hasMoreChemists = true;
  bool _isLoadingMoreChemists = false;

  // Stockists Selection (Multi-select)
  List<Stockist> _availableStockists = [];
  List<Stockist> _paginatedStockists = [];
  final Set<String> _selectedStockistIds = {};
  bool _isLoadingStockists = false;
  bool _hasMoreStockists = true;
  bool _isLoadingMoreStockists = false;

  // Error States
  String? _chemistsError;
  String? _stockistsError;
  String? _productsError;
  String? _historyError;

  // Brands & Products Catalog
  List<Brand> _brands = [];
  String? _selectedBrandId; // null or 'ALL' means all brands
  List<Product> _allProductsForStockists = [];
  List<Product> _filteredProducts = [];
  List<Product> _paginatedProducts = [];
  String _productSearchQuery = '';
  bool _isLoadingProducts = false;
  bool _hasMoreProducts = true;
  bool _isLoadingMoreProducts = false;

  // Product Quantity Entry Map: "productId:stockistId" -> quantity
  final Map<String, int> _productQuantities = {};

  // Location & Submission State
  LocationDataResult? _currentLocation;
  bool _isCapturingLocation = false;
  bool _isSubmitting = false;

  // DCR History
  List<DcrSubmission> _dcrHistory = [];
  List<DcrSubmission> _paginatedHistory = [];
  bool _isLoadingHistory = false;
  bool _hasMoreHistory = true;
  bool _isLoadingMoreHistory = false;

  // Getters
  List<Chemist> get chemists => _paginatedChemists;
  Chemist? get selectedChemist => _selectedChemist;
  bool get isLoadingChemists => _isLoadingChemists;
  String get chemistSearchQuery => _chemistSearchQuery;
  bool get hasMoreChemists => _hasMoreChemists;
  bool get isLoadingMoreChemists => _isLoadingMoreChemists;

  List<Stockist> get availableStockists => _paginatedStockists;
  List<Stockist> get allAvailableStockistsRaw => _availableStockists;
  Set<String> get selectedStockistIds => _selectedStockistIds;
  List<Stockist> get selectedStockistsList => _availableStockists
      .where((s) => _selectedStockistIds.contains(s.id))
      .toList();
  bool get isLoadingStockists => _isLoadingStockists;
  bool get hasMoreStockists => _hasMoreStockists;
  bool get isLoadingMoreStockists => _isLoadingMoreStockists;

  List<Brand> get brands => _brands;
  String? get selectedBrandId => _selectedBrandId;
  List<Product> get products => _paginatedProducts;
  List<Product> get allProductsForSelectedStockists => _allProductsForStockists;
  String get productSearchQuery => _productSearchQuery;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get hasMoreProducts => _hasMoreProducts;
  bool get isLoadingMoreProducts => _isLoadingMoreProducts;

  Map<String, int> get productQuantities => _productQuantities;

  LocationDataResult? get currentLocation => _currentLocation;
  bool get isCapturingLocation => _isCapturingLocation;
  bool get isSubmitting => _isSubmitting;

  List<DcrSubmission> get dcrHistory => _paginatedHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get hasMoreHistory => _hasMoreHistory;
  bool get isLoadingMoreHistory => _isLoadingMoreHistory;

  // Error Getters
  String? get chemistsError => _chemistsError;
  String? get stockistsError => _stockistsError;
  String? get productsError => _productsError;
  String? get historyError => _historyError;

  // Calculations
  int get totalItemsCount =>
      _productQuantities.values.where((qty) => qty > 0).length;

  int get totalUnitsQuantity =>
      _productQuantities.values.fold(0, (sum, qty) => sum + qty);

  double get totalEstimatedValue {
    double total = 0.0;
    _productQuantities.forEach((key, qty) {
      if (qty > 0) {
        final parts = key.split(':');
        final productId = parts[0];
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
            tseEmployeeId: '',
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
    _tseEmployeeId = tseEmployeeId;
    _isLoadingChemists = true;
    _chemistsError = null;
    notifyListeners();

    try {
      _mappedChemists = await _apiService.getMappedChemists(tseEmployeeId);
      _applyChemistFilter();
    } catch (e) {
      _chemistsError = e.toString();
      _mappedChemists = [];
      _filteredChemists = [];
      _paginatedChemists = [];
    } finally {
      _isLoadingChemists = false;
      notifyListeners();
    }
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
    _initChemistsPagination();
  }

  void _initChemistsPagination() {
    _paginatedChemists = _filteredChemists.take(_pageSizeChemists).toList();
    _hasMoreChemists = _filteredChemists.length > _paginatedChemists.length;
    _isLoadingMoreChemists = false;
  }

  Future<void> loadMoreChemists() async {
    if (_isLoadingMoreChemists || !_hasMoreChemists) return;
    _isLoadingMoreChemists = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final currentLength = _paginatedChemists.length;
    final nextBatch = _filteredChemists.skip(currentLength).take(_pageSizeChemists);
    _paginatedChemists.addAll(nextBatch);
    _hasMoreChemists = _filteredChemists.length > _paginatedChemists.length;
    _isLoadingMoreChemists = false;
    notifyListeners();
  }

  Future<void> selectChemist(Chemist chemist) async {
    _selectedChemist = chemist;
    _selectedStockistIds.clear();
    _productQuantities.clear();
    _selectedBrandId = null;
    _productSearchQuery = '';
    _stockistsError = null;
    _productsError = null;
    notifyListeners();

    // Fetch all stockists
    _isLoadingStockists = true;
    notifyListeners();

    try {
      _availableStockists =
          await _apiService.getStockistsForUser(_tseEmployeeId ?? 'TSE-10042');
      _initStockistsPagination();
      await loadProductsForSelectedStockists();
    } catch (e) {
      _stockistsError = e.toString();
      _availableStockists = [];
      _paginatedStockists = [];
    } finally {
      _isLoadingStockists = false;
      notifyListeners();
    }
  }

  // --- Step 2: Multi-Stockist Selection ---
  void _initStockistsPagination() {
    _paginatedStockists = _availableStockists.take(_pageSizeStockists).toList();
    _hasMoreStockists = _availableStockists.length > _paginatedStockists.length;
    _isLoadingMoreStockists = false;
  }

  Future<void> loadMoreStockists() async {
    if (_isLoadingMoreStockists || !_hasMoreStockists) return;
    _isLoadingMoreStockists = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final currentLength = _paginatedStockists.length;
    final nextBatch = _availableStockists.skip(currentLength).take(_pageSizeStockists);
    _paginatedStockists.addAll(nextBatch);
    _hasMoreStockists = _availableStockists.length > _paginatedStockists.length;
    _isLoadingMoreStockists = false;
    notifyListeners();
  }

  Future<void> refreshStockists() async {
    _isLoadingStockists = true;
    _stockistsError = null;
    notifyListeners();

    try {
      _availableStockists =
          await _apiService.getStockistsForUser(_tseEmployeeId ?? 'TSE-10042');
      _initStockistsPagination();
    } catch (e) {
      _stockistsError = e.toString();
      _availableStockists = [];
      _paginatedStockists = [];
    } finally {
      _isLoadingStockists = false;
      notifyListeners();
    }
  }

  void toggleStockist(String stockistId) {
    if (_selectedStockistIds.contains(stockistId)) {
      _selectedStockistIds.remove(stockistId);
      // Remove any product quantities linked to this deselected stockist
      _productQuantities.removeWhere((key, value) => key.endsWith(':$stockistId'));
    } else {
      _selectedStockistIds.add(stockistId);
    }
    loadProductsForSelectedStockists();
    notifyListeners();
  }

  Future<void> loadProductsForSelectedStockists() async {
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();

    try {
      _allProductsForStockists = await _apiService
          .getProductsForUser(_tseEmployeeId ?? 'TSE-10042');
      _applyProductFilter();
    } catch (e) {
      _productsError = e.toString();
      _allProductsForStockists = [];
      _filteredProducts = [];
      _paginatedProducts = [];
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
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
    _initProductsPagination();
  }

  void _initProductsPagination() {
    _paginatedProducts = _filteredProducts.take(_pageSizeProducts).toList();
    _hasMoreProducts = _filteredProducts.length > _paginatedProducts.length;
    _isLoadingMoreProducts = false;
  }

  Future<void> loadMoreProducts() async {
    if (_isLoadingMoreProducts || !_hasMoreProducts) return;
    _isLoadingMoreProducts = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final currentLength = _paginatedProducts.length;
    final nextBatch = _filteredProducts.skip(currentLength).take(_pageSizeProducts);
    _paginatedProducts.addAll(nextBatch);
    _hasMoreProducts = _filteredProducts.length > _paginatedProducts.length;
    _isLoadingMoreProducts = false;
    notifyListeners();
  }

  void updateQuantity(String productId, String stockistId, int quantity) {
    final key = '$productId:$stockistId';
    if (quantity <= 0) {
      _productQuantities.remove(key);
    } else {
      _productQuantities[key] = quantity;
    }
    notifyListeners();
  }

  void incrementQuantity(String productId, String stockistId) {
    final key = '$productId:$stockistId';
    int current = _productQuantities[key] ?? 0;
    _productQuantities[key] = current + 1;
    notifyListeners();
  }

  void decrementQuantity(String productId, String stockistId) {
    final key = '$productId:$stockistId';
    int current = _productQuantities[key] ?? 0;
    if (current > 1) {
      _productQuantities[key] = current - 1;
    } else {
      _productQuantities.remove(key);
    }
    notifyListeners();
  }

  int getQuantity(String productId, String stockistId) =>
      _productQuantities['$productId:$stockistId'] ?? 0;

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
    _productQuantities.forEach((key, qty) {
      if (qty > 0) {
        final parts = key.split(':');
        final productId = parts[0];
        final stockistId = parts[1];
        final product = _allProductsForStockists.firstWhere((p) => p.id == productId);
        final stockist = _availableStockists.firstWhere((s) => s.id == stockistId);
        items.add(DcrItem(
          productId: product.id,
          productName: product.name,
          brandName: product.brandName,
          packSize: product.packSize,
          quantity: qty,
          ptr: product.ptr,
          stockistId: stockist.id,
          stockistName: stockist.name,
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
      _initHistoryPagination();
      clearQuantities();
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  void clearQuantities() {
    _productQuantities.clear();
    _currentLocation = null;
    _productsError = null;
    _historyError = null;
    notifyListeners();
  }

  Future<void> fetchDcrHistory() async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      _dcrHistory = await _apiService.getDcrHistory();
      _initHistoryPagination();
    } catch (e) {
      _historyError = e.toString();
      _dcrHistory = [];
      _paginatedHistory = [];
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void _initHistoryPagination() {
    _paginatedHistory = _dcrHistory.take(_pageSizeHistory).toList();
    _hasMoreHistory = _dcrHistory.length > _paginatedHistory.length;
    _isLoadingMoreHistory = false;
  }

  Future<void> loadMoreHistory() async {
    if (_isLoadingMoreHistory || !_hasMoreHistory) return;
    _isLoadingMoreHistory = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final currentLength = _paginatedHistory.length;
    final nextBatch = _dcrHistory.skip(currentLength).take(_pageSizeHistory);
    _paginatedHistory.addAll(nextBatch);
    _hasMoreHistory = _dcrHistory.length > _paginatedHistory.length;
    _isLoadingMoreHistory = false;
    notifyListeners();
  }

  void resetWorkflow() {
    _selectedChemist = null;
    _selectedStockistIds.clear();
    _availableStockists.clear();
    _paginatedStockists.clear();
    _allProductsForStockists.clear();
    _filteredProducts.clear();
    _paginatedProducts.clear();
    _productQuantities.clear();
    _selectedBrandId = null;
    _productSearchQuery = '';
    _chemistSearchQuery = '';
    _currentLocation = null;
    _chemistsError = null;
    _stockistsError = null;
    _productsError = null;
    _historyError = null;
    notifyListeners();
  }

  void clearAllData() {
    _mappedChemists = [];
    _filteredChemists = [];
    _paginatedChemists = [];
    _selectedChemist = null;
    _chemistSearchQuery = '';
    _isLoadingChemists = false;
    _hasMoreChemists = true;
    _isLoadingMoreChemists = false;

    _availableStockists = [];
    _paginatedStockists = [];
    _selectedStockistIds.clear();
    _isLoadingStockists = false;
    _hasMoreStockists = true;
    _isLoadingMoreStockists = false;

    _chemistsError = null;
    _stockistsError = null;
    _productsError = null;
    _historyError = null;

    _allProductsForStockists = [];
    _filteredProducts = [];
    _paginatedProducts = [];
    _productSearchQuery = '';
    _isLoadingProducts = false;
    _hasMoreProducts = true;
    _isLoadingMoreProducts = false;

    _productQuantities.clear();

    _currentLocation = null;
    _isCapturingLocation = false;
    _isSubmitting = false;

    _dcrHistory = [];
    _paginatedHistory = [];
    _isLoadingHistory = false;
    _hasMoreHistory = true;
    _isLoadingMoreHistory = false;

    notifyListeners();
  }
}
