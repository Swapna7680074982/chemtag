import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../core/constants/app_colors.dart';

class SystemInfoScreen extends StatelessWidget {
  const SystemInfoScreen({super.key});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label copied to clipboard',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppColors.accent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'System & API Information',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(
                icon: Icon(Icons.phone_android_rounded, size: 20),
                text: 'Device Profile',
              ),
              Tab(
                icon: Icon(Icons.api_rounded, size: 20),
                text: 'API Docs',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDeviceTab(context, apiService),
            _buildApiTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTab(BuildContext context, ApiService apiService) {
    final deviceDetails = [
      {
        'title': 'Device Identifier',
        'value': apiService.deviceId,
        'icon': Icons.fingerprint_rounded,
        'color': AppColors.primary,
        'description': 'Unique device hash sent to security servers.'
      },
      {
        'title': 'Device Name',
        'value': apiService.deviceName,
        'icon': Icons.devices_rounded,
        'color': AppColors.accent,
        'description': 'Model name reported to the chemist-app auth.'
      },
      {
        'title': 'Operating System',
        'value': apiService.osVersion,
        'icon': Icons.settings_suggest_rounded,
        'color': AppColors.warning,
        'description': 'Operating system environment & platform version.'
      },
      {
        'title': 'Platform Target',
        'value': apiService.platform,
        'icon': Icons.android_rounded,
        'color': AppColors.success,
        'description': 'Mobile application platform core compilation.'
      },
      {
        'title': 'App Version',
        'value': apiService.appVersion,
        'icon': Icons.system_update_alt_rounded,
        'color': AppColors.info,
        'description': 'Current installed ChemTag release package.'
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Profile Configuration',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Below are the system metadata fields sent with authentication and session refresh requests to track authorized devices.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...deviceDetails.map((device) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              onTap: () => _copyToClipboard(
                context,
                device['value'] as String,
                device['title'] as String,
              ),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (device['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        device['icon'] as IconData,
                        color: device['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device['title'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            device['value'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            device['description'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildApiTab(BuildContext context) {
    final apis = _getApiList();

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.surface,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TSE Chemist App API Reference',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.dns_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        children: const [
                          TextSpan(text: 'Base Domain: '),
                          TextSpan(
                            text: 'https://services.heterohcl.com',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _copyToClipboard(
                      context,
                      'https://services.heterohcl.com',
                      'Domain',
                    ),
                    icon: const Icon(Icons.copy, size: 12, color: AppColors.primary),
                    label: Text(
                      'Copy',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: apis.length,
            itemBuilder: (ctx, index) {
              final api = apis[index];
              final bool isPost = api['method'] == 'POST';

              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPost ? AppColors.primary.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        api['method'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isPost ? AppColors.primary : AppColors.success,
                        ),
                      ),
                    ),
                    title: Text(
                      api['name'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      api['path'] as String,
                      style: GoogleFonts.firaCode(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    children: [
                      const Divider(height: 1, color: AppColors.border),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Full URL row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'URL: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Expanded(
                                  child: SelectableText(
                                    api['url'] as String,
                                    style: GoogleFonts.firaCode(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _copyToClipboard(
                                    context,
                                    api['url'] as String,
                                    'Endpoint URL',
                                  ),
                                  child: const Icon(
                                    Icons.copy_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Auth token required
                            if (api['hasAuth'] == true) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lock_person_outlined,
                                    color: AppColors.warning,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Access Token: Bearer Token Required',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            // Request body
                            if (api['input'] != null && api['input'] != 'NA') ...[
                              Text(
                                'Request Payload:',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildCodeBlock(context, api['input'] as String),
                              const SizedBox(height: 12),
                            ],
                            // Expected Response
                            Text(
                              'Expected Success Response:',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildCodeBlock(context, api['response'] as String),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBlock(BuildContext context, String jsonText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Slate 900
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              jsonText,
              style: GoogleFonts.firaCode(
                fontSize: 11,
                color: const Color(0xFFE2E8F0), // Slate 200
                height: 1.4,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _copyToClipboard(context, jsonText, 'JSON Schema'),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getApiList() {
    return [
      {
        'name': 'Login API',
        'method': 'POST',
        'path': '/api/auth/login',
        'url': 'https://services.heterohcl.com/chemist-app/api/auth/login',
        'hasAuth': false,
        'input': '''{
  "employeeId": "13995",
  "password": "hetero123",
  "deviceId": "123-56",
  "deviceName": "Samsung Galaxy A55",
  "platform": "ANDROID",
  "osVersion": "Android 15",
  "appVersion": "1.0.0"
}''',
        'response': '''{
  "status": true,
  "code": "LOGIN_SUCCESS",
  "message": "Login successful.",
  "data": {
    "accessToken": "eyJ0eXAi...",
    "accessTokenType": "Bearer",
    "accessTokenExpiresIn": 7200,
    "accessTokenExpiresAt": "2026-08-11 12:08:06",
    "refreshToken": "rt1.rqSA...",
    "refreshTokenExpiresAt": "2026-09-10 10:08:06",
    "profile": {
      "employeeId": "13995",
      "employeeName": "HRISHIKESH SUBHASH SALEKAR",
      "buCode": "19",
      "buName": "HHC - DIASPA",
      "email": "diaspapune.fe4@heterohealthcare.com",
      "mobile": "8459733167",
      "pic": "https://sso.heterohcl.com/iconnectpics/13995/1000702488.jpg",
      "hq": "PUNE",
      "region": "MH-PUNE",
      "designation": "TSE",
      "designationId": "1",
      "managerEmployeeId": null,
      "state": "MAHARASHTRA",
      "employeeType": "Field",
      "employeeStatus": null,
      "divisionId": "15",
      "divisionName": "HHC - DIASPA - Hetero",
      "isTse": true,
      "tseDetails": [
        {
          "employeeCode": "13995",
          "empName": "HRISHIKESH SUBHASH SALEKAR",
          "designation": "TSE/MR/TM",
          "division": "HHC - DIASPA - Hetero",
          "divisionid": "15",
          "hq": "PUNE"
        }
      ]
    }
  }
}''',
      },
      {
        'name': 'Logout API',
        'method': 'POST',
        'path': '/api/auth/logout',
        'url': 'https://services.heterohcl.com/chemist-app/api/auth/logout',
        'hasAuth': true,
        'input': '''{
  "refreshToken": "rt1.J0aXPwWWgvtUUf8tn1V_RNkzAnGa7LWnnl6wuFseOvoky90vhuZiOALSGHVrT11D"
}''',
        'response': '''{
  "status": true,
  "code": "LOGOUT_SUCCESS",
  "message": "Logout successful."
}''',
      },
      {
        'name': 'Refresh Token API',
        'method': 'POST',
        'path': '/api/auth/refresh',
        'url': 'https://services.heterohcl.com/chemist-app/api/auth/refresh',
        'hasAuth': false,
        'input': '''{
  "refreshToken": "rt1.w8F7Y9X0bo2dM2__tUpRAP0KEIJ_qM8Q9gtCkSn3jBcFU0ljTNPCCEhEAyPKKwOC",
  "deviceId": "123-56"
}''',
        'response': '''{
  "status": true,
  "code": "TOKEN_REFRESH_SUCCESS",
  "message": "Token refreshed successfully.",
  "data": {
    "accessToken": "eyJ0eXAi...",
    "accessTokenType": "Bearer",
    "accessTokenExpiresIn": 900,
    "accessTokenExpiresAt": "2026-08-10 09:08:24",
    "refreshToken": "rt1.p7O6...",
    "refreshTokenExpiresAt": "2026-09-09 08:36:29"
  }
}''',
      },
      {
        'name': 'Profile API',
        'method': 'GET',
        'path': '/api/auth/profile',
        'url': 'https://services.heterohcl.com/chemist-app/api/auth/profile',
        'hasAuth': true,
        'input': null,
        'response': '''{
  "status": true,
  "code": "PROFILE_SUCCESS",
  "message": "Profile fetched successfully.",
  "data": {
    "profile": {
      "employeeId": "13995",
      "employeeName": "HRISHIKESH SUBHASH SALEKAR",
      "buCode": "19",
      "buName": "HHC - DIASPA",
      "email": "diaspapune.fe4@heterohealthcare.com",
      "mobile": "8459733167",
      "pic": "https://sso.heterohcl.com/iconnectpics/13995/1000702488.jpg",
      "hq": "PUNE",
      "region": "MH-PUNE",
      "designation": "TSE",
      "designationId": "1",
      "managerEmployeeId": null,
      "state": "MAHARASHTRA",
      "employeeType": "Field",
      "employeeStatus": null,
      "divisionId": "15",
      "divisionName": "HHC - DIASPA - Hetero",
      "isTse": true,
      "tseDetails": [
        {
          "employeeCode": "13995",
          "empName": "HRISHIKESH SUBHASH SALEKAR",
          "designation": "TSE/MR/TM",
          "division": "HHC - DIASPA - Hetero",
          "divisionid": "15",
          "hq": "PUNE"
        }
      ]
    }
  }
}''',
      },
      {
        'name': 'Chemists List API',
        'method': 'GET',
        'path': '/api/master/chemists',
        'url': 'https://services.heterohcl.com/chemist-app/api/master/chemists',
        'hasAuth': true,
        'input': null,
        'response': '''{
  "status": true,
  "code": "CHEMISTS_SUCCESS",
  "message": "Chemists fetched successfully.",
  "dataSource": "THIRD_PARTY",
  "data": {
    "chemists": [
      {
        "divisionCode": "01",
        "division": "HHCLMAIN",
        "region": "TELANGANA",
        "hq": "MANCHERIAL",
        "empCode": "105140",
        "empName": "SATHISH MUTHYAM",
        "chemistcode": "C48505",
        "chemistName": "PAWANASUTHA MEDICAL",
        "mobileNumber": "9966009007"
      },
      {
        "divisionCode": "01",
        "division": "HHCLMAIN",
        "region": "TELANGANA",
        "hq": "MANCHERIAL",
        "empCode": "105140",
        "empName": "SATHISH MUTHYAM",
        "chemistcode": "C48506",
        "chemistName": "MAHAVEER MEDICAL",
        "mobileNumber": "9866973136"
      }
    ]
  }
}''',
      },
      {
        'name': 'Stockists List API',
        'method': 'GET',
        'path': '/api/master/stockists',
        'url': 'https://services.heterohcl.com/chemist-app/api/master/stockists',
        'hasAuth': true,
        'input': null,
        'response': '''{
  "status": true,
  "code": "STOCKISTS_SUCCESS",
  "message": "Stockists fetched successfully.",
  "dataSource": "THIRD_PARTY",
  "data": {
    "stockists": [
      {
        "stockistSapId": "2061851",
        "stockistName": "SRI SRINIVASA PHARMA DISTRIBUTORS",
        "divisionSapId": "01",
        "citySapId": "S045",
        "hqName": "MANCHEREL"
      },
      {
        "stockistSapId": "2061851",
        "stockistName": "SRI SRINIVASA PHARMA DISTRIBUTORS",
        "divisionSapId": "05",
        "citySapId": "S045",
        "hqName": "MANCHEREL"
      }
    ]
  }
}''',
      },
      {
        'name': 'Products List API',
        'method': 'GET',
        'path': '/api/master/products',
        'url': 'https://services.heterohcl.com/chemist-app/api/master/products',
        'hasAuth': true,
        'input': null,
        'response': '''{
  "status": true,
  "code": "PRODUCTS_SUCCESS",
  "message": "Products fetched successfully.",
  "dataSource": "THIRD_PARTY",
  "data": {
    "products": [
      {
        "productId": "14000019",
        "productCode": "14000019",
        "materialCode": "14000019",
        "productName": "GEMTERO 200 MG INJ (VIAL)",
        "materialName": "GEMTERO 200 MG INJ (VIAL)",
        "divisionCode": "15",
        "packSize": "",
        "unit": ""
      },
      {
        "productId": "14000029",
        "productCode": "14000029",
        "materialCode": "14000029",
        "productName": "LINOWIN 600 MG TABS 10'S",
        "materialName": "LINOWIN 600 MG TABS 10'S",
        "divisionCode": "15",
        "packSize": "",
        "unit": ""
      }
    ]
  }
}''',
      },
      {
        'name': 'Submit Stocks API',
        'method': 'POST',
        'path': '/api/stocks/submit',
        'url': 'https://services.heterohcl.com/chemist-app/api/stocks/submit',
        'hasAuth': true,
        'input': '''// Without stockist:
{
  "chemistCode": "R170019",
  "items": [
    {"materialCode": "14000019", "quantity": 10}
  ],
  "latitude": 18.8756,
  "longitude": 79.4591
}

// With stockist:
{
  "chemistCode": "C48505",
  "stockistSapIds": ["2061851", "2064321"],
  "items": [
    {"materialCode": "14000019", "quantity": 9}
  ],
  "latitude": 18.8756,
  "longitude": 79.4591
}''',
        'response': '''{
  "status": true,
  "code": "STOCK_SUBMIT_SUCCESS",
  "message": "Stock submitted successfully.",
  "dataSource": "THIRD_PARTY",
  "data": {
    "orderId": 3,
    "orderNo": "STK-20260811100927-13995-B3E129",
    "chemist": {
      "chemistCode": "R170019",
      "chemistName": "SHASHWAT HOSP PHARMACY"
    },
    "stockists": [],
    "stockist": null,
    "items": [
      {
        "materialCode": "14000019",
        "materialName": "GEMTERO 200 MG INJ (VIAL)",
        "divisionCode": "15",
        "quantity": 10
      }
    ],
    "submittedAt": "2026-08-11 10:09:27"
  }
}''',
      },
      {
        'name': 'Submitted Stocks API',
        'method': 'GET',
        'path': '/api/stocks/submitted',
        'url': 'https://services.heterohcl.com/chemist-app/api/stocks/submitted',
        'hasAuth': true,
        'input': null,
        'response': '''{
  "status": true,
  "code": "SUBMITTED_STOCKS_SUCCESS",
  "message": "Submitted stocks fetched successfully.",
  "data": {
    "page": 1,
    "limit": 20,
    "total": 2,
    "records": [
      {
        "orderId": 3,
        "orderNo": "STK-20260811100927-13995-B3E129",
        "chemist": {
          "chemistId": "R170019",
          "chemistCode": "R170019",
          "chemistName": "SHASHWAT HOSP PHARMACY",
          "mobileNumber": "2067296600",
          "divisionCode": "15",
          "division": "DIASPA",
          "region": "MH-PUNE",
          "hq": "PUNE"
        },
        "stockists": [],
        "stockist": null,
        "items": [
          {
            "productId": "14000019",
            "productCode": "14000019",
            "productName": "GEMTERO 200 MG INJ (VIAL)",
            "quantity": "10",
            "divisionCode": "15",
            "materialCode": "14000019",
            "materialName": "GEMTERO 200 MG INJ (VIAL)"
          }
        ],
        "location": {
          "latitude": 18.8756,
          "longitude": 79.4591,
          "gpsAccuracyMeters": null,
          "capturedAt": "2026-08-11 10:09:27"
        },
        "status": "SUBMITTED",
        "submittedAt": "2026-08-11 10:09:27"
      }
    ]
  }
}''',
      },
    ];
  }
}
