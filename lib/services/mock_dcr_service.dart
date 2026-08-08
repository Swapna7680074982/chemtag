import '../models/tse_user.dart';
import '../models/chemist.dart';
import '../models/stockist.dart';
import '../models/brand.dart';
import '../models/product.dart';
import '../models/dcr_submission.dart';

class MockDcrService {
  // Simulated TSE user profile
  final TseUser mockUser = TseUser(
    employeeId: 'TSE-10042',
    name: 'Nikhita Grover',
    email: 'nikhita.grover@chemtag.com',
    designation: 'Senior Territory Sales Executive',
    territory: 'Delhi NCR - Region 4',
    hqCity: 'New Delhi',
    phone: '+91 98765 43210',
  );

  // Mapped Chemists list
  final List<Chemist> _allChemists = [
    Chemist(
      id: 'CHM-101',
      storeName: 'Apollo Pharmacy - Connaught Place',
      ownerName: 'Rajesh Sharma',
      licenseNo: 'DL-2026-9812',
      locality: 'Connaught Place, Inner Circle',
      city: 'New Delhi',
      phone: '+91 98110 12345',
      category: 'A+',
      tseEmployeeId: 'TSE-10042',
      mappedStockistIds: ['STK-001', 'STK-002', 'STK-003'],
    ),
    Chemist(
      id: 'CHM-102',
      storeName: 'MedPlus Chemist & Druggists',
      ownerName: 'Sanjay Verma',
      licenseNo: 'DL-2025-4421',
      locality: 'Rajouri Garden Main Market',
      city: 'New Delhi',
      phone: '+91 98711 54321',
      category: 'A',
      tseEmployeeId: 'TSE-10042',
      mappedStockistIds: ['STK-001', 'STK-004'],
    ),
    Chemist(
      id: 'CHM-103',
      storeName: 'Care Pharmacy & Surgical Store',
      ownerName: 'Amitabh Gupta',
      licenseNo: 'DL-2026-1189',
      locality: 'Lajpat Nagar Central Market',
      city: 'New Delhi',
      phone: '+91 99100 87654',
      category: 'A+',
      tseEmployeeId: 'TSE-10042',
      mappedStockistIds: ['STK-002', 'STK-003'],
    ),
    Chemist(
      id: 'CHM-104',
      storeName: 'Wellness Chemist Store',
      ownerName: 'Pooja Malhotra',
      licenseNo: 'DL-2024-7734',
      locality: 'Karol Bagh Market',
      city: 'New Delhi',
      phone: '+91 98990 33221',
      category: 'B',
      tseEmployeeId: 'TSE-10042',
      mappedStockistIds: ['STK-001', 'STK-003', 'STK-004'],
    ),
    Chemist(
      id: 'CHM-105',
      storeName: 'Lifeline Medicos',
      ownerName: 'Ramanathan Iyer',
      licenseNo: 'DL-2026-3001',
      locality: 'South Extension Part II',
      city: 'New Delhi',
      phone: '+91 98401 99887',
      category: 'A',
      tseEmployeeId: 'TSE-10042',
      mappedStockistIds: ['STK-002', 'STK-004'],
    ),
  ];

  // Stockists catalog
  final List<Stockist> _allStockists = [
    Stockist(
      id: 'STK-001',
      name: 'Apex Pharma Distributors Ltd.',
      code: 'APX-DEL-01',
      contactPerson: 'Harish Mehta',
      phone: '+91 98100 00111',
      address: 'Plot 42, Okhla Industrial Area Ph-III',
      city: 'New Delhi',
    ),
    Stockist(
      id: 'STK-002',
      name: 'Medivision Wholesale Medical Agency',
      code: 'MDV-DEL-02',
      contactPerson: 'Vikas Bansal',
      phone: '+91 98111 22334',
      address: 'Building 14, Bhagirath Palace, Chandni Chowk',
      city: 'Delhi',
    ),
    Stockist(
      id: 'STK-003',
      name: 'Sunrise Healthcare Logistics',
      code: 'SHL-DEL-03',
      contactPerson: 'Gurpreet Singh',
      phone: '+91 98999 55443',
      address: 'Sector 18, Udyog Vihar',
      city: 'Gurugram',
    ),
    Stockist(
      id: 'STK-004',
      name: 'Universal Medical Agencies',
      code: 'UMA-DEL-04',
      contactPerson: 'Rakesh Khurana',
      phone: '+91 98122 77665',
      address: 'Pocket B, Naraina Industrial Area',
      city: 'New Delhi',
    ),
  ];

  // Brands catalog
  final List<Brand> _allBrands = [
    Brand(
      id: 'BRD-01',
      name: 'Metabocare',
      category: 'Endocrinology & Diabetes',
      description: 'Oral GLP-1 & Metformin Formulations',
    ),
    Brand(
      id: 'BRD-02',
      name: 'CardioShield',
      category: 'Cardiology',
      description: 'Hypertension & Lipid Control Range',
    ),
    Brand(
      id: 'BRD-03',
      name: 'NeuroPulse',
      category: 'Neurology',
      description: 'Neuroprotective & Neuropathic Pain Relief',
    ),
    Brand(
      id: 'BRD-04',
      name: 'GastroHeal',
      category: 'Gastroenterology',
      description: 'PPIs & Anti-ulceratives',
    ),
    Brand(
      id: 'BRD-05',
      name: 'DermaGlow',
      category: 'Dermatology',
      description: 'Topical Steroids & Antifungals',
    ),
  ];

  // Products catalog
  final List<Product> _allProducts = [
    Product(
      id: 'PRD-101',
      name: 'Semaglutide 14mg Tablets',
      skuCode: 'SEM-14-TAB',
      brandId: 'BRD-01',
      brandName: 'Metabocare',
      packSize: '10 Tablets / Strip',
      ptr: 450.00,
      mrp: 520.00,
      inStock: true,
      availableStockistIds: ['STK-001', 'STK-002', 'STK-003'],
    ),
    Product(
      id: 'PRD-102',
      name: 'Semaglutide 7mg Tablets',
      skuCode: 'SEM-07-TAB',
      brandId: 'BRD-01',
      brandName: 'Metabocare',
      packSize: '10 Tablets / Strip',
      ptr: 320.00,
      mrp: 375.00,
      inStock: true,
      availableStockistIds: ['STK-001', 'STK-002', 'STK-004'],
    ),
    Product(
      id: 'PRD-103',
      name: 'Metformin SR 1000mg',
      skuCode: 'MET-1000-SR',
      brandId: 'BRD-01',
      brandName: 'Metabocare',
      packSize: '15 Tablets / Strip',
      ptr: 85.00,
      mrp: 105.00,
      inStock: true,
      availableStockistIds: ['STK-001', 'STK-003', 'STK-004'],
    ),
    Product(
      id: 'PRD-201',
      name: 'Telmisartan 40mg + Amlodipine 5mg',
      skuCode: 'TEL-AML-40',
      brandId: 'BRD-02',
      brandName: 'CardioShield',
      packSize: '15 Tablets / Strip',
      ptr: 110.00,
      mrp: 135.00,
      inStock: true,
      availableStockistIds: ['STK-001', 'STK-002'],
    ),
    Product(
      id: 'PRD-202',
      name: 'Rosuvastatin 20mg',
      skuCode: 'ROS-20-TAB',
      brandId: 'BRD-02',
      brandName: 'CardioShield',
      packSize: '10 Tablets / Strip',
      ptr: 175.00,
      mrp: 210.00,
      inStock: true,
      availableStockistIds: ['STK-002', 'STK-003', 'STK-004'],
    ),
    Product(
      id: 'PRD-301',
      name: 'Pregabalin 75mg + Methylcobalamin',
      skuCode: 'PRE-METH-75',
      brandId: 'BRD-03',
      brandName: 'NeuroPulse',
      packSize: '10 Capsules / Strip',
      ptr: 190.00,
      mrp: 230.00,
      inStock: true,
      availableStockistIds: ['STK-001', 'STK-004'],
    ),
    Product(
      id: 'PRD-401',
      name: 'Rabeprazole 20mg + Domperidone 30mg SR',
      skuCode: 'RAB-DOM-SR',
      brandId: 'BRD-04',
      brandName: 'GastroHeal',
      packSize: '10 Capsules / Strip',
      ptr: 125.00,
      mrp: 150.00,
      inStock: true,
      availableStockistIds: ['STK-002', 'STK-003'],
    ),
    Product(
      id: 'PRD-501',
      name: 'Luliconazole Cream 1% w/w',
      skuCode: 'LUL-CRM-30',
      brandId: 'BRD-05',
      brandName: 'DermaGlow',
      packSize: '30g Tube',
      ptr: 210.00,
      mrp: 260.00,
      inStock: true,
      availableStockistIds: ['STK-001', 'STK-003', 'STK-004'],
    ),
  ];

  // In-memory submissions database
  final List<DcrSubmission> _submittedDcrs = [];

  // API Methods
  Future<TseUser> login(String employeeId, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (employeeId.trim().toUpperCase() == 'TSE-10042' || employeeId.trim().isEmpty) {
      return mockUser;
    }
    // Default fallback to mockUser for easy demonstration
    return mockUser;
  }

  Future<List<Chemist>> getMappedChemists(String tseEmployeeId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _allChemists
        .where((c) => c.tseEmployeeId == tseEmployeeId || true)
        .toList();
  }

  Future<List<Stockist>> getStockistsForChemist(List<String> mappedStockistIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allStockists
        .where((s) => mappedStockistIds.contains(s.id))
        .toList();
  }

  Future<List<Brand>> getBrands() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allBrands;
  }

  Future<List<Product>> getProductsForStockists(List<String> selectedStockistIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (selectedStockistIds.isEmpty) return [];
    return _allProducts.where((product) {
      return product.availableStockistIds
          .any((stkId) => selectedStockistIds.contains(stkId));
    }).toList();
  }

  Future<bool> submitDcrReport(DcrSubmission submission) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _submittedDcrs.insert(0, submission);
    return true;
  }

  Future<List<DcrSubmission>> getDcrHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _submittedDcrs;
  }
}
