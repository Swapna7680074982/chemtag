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
    ),
    Chemist(
      id: 'CHM-106',
      storeName: 'Fortis Healthworld - Greater Kailash',
      ownerName: 'Nitin Kapoor',
      licenseNo: 'DL-2026-5542',
      locality: 'Greater Kailash I, M-Block',
      city: 'New Delhi',
      phone: '+91 98112 34567',
      category: 'A+',
      tseEmployeeId: 'TSE-10042',
    ),
    Chemist(
      id: 'CHM-107',
      storeName: 'Guardian Pharmacy - GK II',
      ownerName: 'Sunita Roy',
      licenseNo: 'DL-2025-8891',
      locality: 'Greater Kailash II',
      city: 'New Delhi',
      phone: '+91 98712 98765',
      category: 'A',
      tseEmployeeId: 'TSE-10042',
    ),
    Chemist(
      id: 'CHM-108',
      storeName: 'Sanjeevani Chemist & Druggists',
      ownerName: 'Deepak Chawla',
      licenseNo: 'DL-2026-1243',
      locality: 'Saket District Centre',
      city: 'New Delhi',
      phone: '+91 99102 33445',
      category: 'B',
      tseEmployeeId: 'TSE-10042',
    ),
    Chemist(
      id: 'CHM-109',
      storeName: 'Max Medicos - Saket',
      ownerName: 'Vikram Malhotra',
      licenseNo: 'DL-2024-9980',
      locality: 'Saket Press Enclave',
      city: 'New Delhi',
      phone: '+91 98990 66778',
      category: 'A+',
      tseEmployeeId: 'TSE-10042',
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
      tseEmployeeId: 'TSE-10042',
    ),
    Stockist(
      id: 'STK-002',
      name: 'Medivision Wholesale Medical Agency',
      code: 'MDV-DEL-02',
      contactPerson: 'Vikas Bansal',
      phone: '+91 98111 22334',
      address: 'Building 14, Bhagirath Palace, Chandni Chowk',
      city: 'Delhi',
      tseEmployeeId: 'TSE-10042',
    ),
    Stockist(
      id: 'STK-003',
      name: 'Sunrise Healthcare Logistics',
      code: 'SHL-DEL-03',
      contactPerson: 'Gurpreet Singh',
      phone: '+91 98999 55443',
      address: 'Sector 18, Udyog Vihar',
      city: 'Gurugram',
      tseEmployeeId: 'TSE-10042',
    ),
    Stockist(
      id: 'STK-004',
      name: 'Universal Medical Agencies',
      code: 'UMA-DEL-04',
      contactPerson: 'Rakesh Khurana',
      phone: '+91 98122 77665',
      address: 'Pocket B, Naraina Industrial Area',
      city: 'New Delhi',
      tseEmployeeId: 'TSE-10042',
    ),
    Stockist(
      id: 'STK-005',
      name: 'Capital Pharma Distributors',
      code: 'CPD-DEL-05',
      contactPerson: 'Sanjay Rawat',
      phone: '+91 98115 55443',
      address: 'Industrial Area Phase I, Mayapuri',
      city: 'New Delhi',
      tseEmployeeId: 'TSE-10042',
    ),
    Stockist(
      id: 'STK-006',
      name: 'Balaji Medical & Surgical Distributors',
      code: 'BMS-DEL-06',
      contactPerson: 'Anil Agarwal',
      phone: '+91 98716 66778',
      address: 'Bhagirath Palace, Chandni Chowk',
      city: 'Delhi',
      tseEmployeeId: 'TSE-10042',
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
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-102',
      name: 'Semaglutide 7mg Tablets',
      skuCode: 'SEM-07-TAB',
      brandId: 'BRD-01',
      brandName: 'Metabocare',
      packSize: '10 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-103',
      name: 'Metformin SR 1000mg',
      skuCode: 'MET-1000-SR',
      brandId: 'BRD-01',
      brandName: 'Metabocare',
      packSize: '15 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-201',
      name: 'Telmisartan 40mg + Amlodipine 5mg',
      skuCode: 'TEL-AML-40',
      brandId: 'BRD-02',
      brandName: 'CardioShield',
      packSize: '15 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-202',
      name: 'Rosuvastatin 20mg',
      skuCode: 'ROS-20-TAB',
      brandId: 'BRD-02',
      brandName: 'CardioShield',
      packSize: '10 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-301',
      name: 'Pregabalin 75mg + Methylcobalamin',
      skuCode: 'PRE-METH-75',
      brandId: 'BRD-03',
      brandName: 'NeuroPulse',
      packSize: '10 Capsules / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-401',
      name: 'Rabeprazole 20mg + Domperidone 30mg SR',
      skuCode: 'RAB-DOM-SR',
      brandId: 'BRD-04',
      brandName: 'GastroHeal',
      packSize: '10 Capsules / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-501',
      name: 'Luliconazole Cream 1% w/w',
      skuCode: 'LUL-CRM-30',
      brandId: 'BRD-05',
      brandName: 'DermaGlow',
      packSize: '30g Tube',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-104',
      name: 'Metformin SR 500mg',
      skuCode: 'MET-500-SR',
      brandId: 'BRD-01',
      brandName: 'Metabocare',
      packSize: '15 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-105',
      name: 'Dapagliflozin 10mg Tablets',
      skuCode: 'DAP-10-TAB',
      brandId: 'BRD-01',
      brandName: 'Metabocare',
      packSize: '10 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-203',
      name: 'Telmisartan 80mg Tablets',
      skuCode: 'TEL-80-TAB',
      brandId: 'BRD-02',
      brandName: 'CardioShield',
      packSize: '15 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-204',
      name: 'Rosuvastatin 10mg Tablets',
      skuCode: 'ROS-10-TAB',
      brandId: 'BRD-02',
      brandName: 'CardioShield',
      packSize: '10 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-205',
      name: 'Atorvastatin 20mg Tablets',
      skuCode: 'ATO-20-TAB',
      brandId: 'BRD-02',
      brandName: 'CardioShield',
      packSize: '10 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-302',
      name: 'Gabapentin 300mg Tablets',
      skuCode: 'GAB-300-TAB',
      brandId: 'BRD-03',
      brandName: 'NeuroPulse',
      packSize: '10 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-303',
      name: 'Methylcobalamin 1500mcg Tablets',
      skuCode: 'METH-1500-TAB',
      brandId: 'BRD-03',
      brandName: 'NeuroPulse',
      packSize: '10 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-402',
      name: 'Pantoprazole 40mg Tablets',
      skuCode: 'PAN-40-TAB',
      brandId: 'BRD-04',
      brandName: 'GastroHeal',
      packSize: '10 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-403',
      name: 'Domperidone 10mg Tablets',
      skuCode: 'DOM-10-TAB',
      brandId: 'BRD-04',
      brandName: 'GastroHeal',
      packSize: '10 Tablets / Strip',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
    ),
    Product(
      id: 'PRD-502',
      name: 'Ketoconazole Shampoo 2% w/v',
      skuCode: 'KET-SHM-100',
      brandId: 'BRD-05',
      brandName: 'DermaGlow',
      packSize: '100ml Bottle',
      inStock: true,
      tseEmployeeId: 'TSE-10042',
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
        .where((c) => c.tseEmployeeId == tseEmployeeId)
        .toList();
  }

  Future<List<Stockist>> getStockistsForChemist(List<String> mappedStockistIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allStockists;
  }

  Future<List<Stockist>> getAllStockists() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allStockists;
  }

  Future<List<Stockist>> getStockistsForUser(String tseEmployeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allStockists
        .where((s) => s.tseEmployeeId == tseEmployeeId)
        .toList();
  }

  Future<List<Brand>> getBrands() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allBrands;
  }

  Future<List<Product>> getProductsForStockists(List<String> selectedStockistIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (selectedStockistIds.isEmpty) return [];
    return _allProducts;
  }

  Future<List<Product>> getProductsForUser(String tseEmployeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allProducts
        .where((p) => p.tseEmployeeId == tseEmployeeId)
        .toList();
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
