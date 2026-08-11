import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/dcr_provider.dart';
import '../widgets/stockist_chip.dart';
import '../widgets/custom_text_field.dart';
import '../core/constants/app_colors.dart';
import 'product_catalog_screen.dart';

class StockistSelectionScreen extends StatefulWidget {
  const StockistSelectionScreen({super.key});

  @override
  State<StockistSelectionScreen> createState() => _StockistSelectionScreenState();
}

class _StockistSelectionScreenState extends State<StockistSelectionScreen> {
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    final dcrProvider = Provider.of<DcrProvider>(context, listen: false);
    _searchController = TextEditingController(text: dcrProvider.stockistSearchQuery);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dcrProvider.refreshStockists();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final dcrProvider = Provider.of<DcrProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      dcrProvider.loadMoreStockists();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dcrProvider = Provider.of<DcrProvider>(context);
    final chemist = dcrProvider.selectedChemist;
    final selectedCount = dcrProvider.selectedStockistIds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 2 of 4: Select Stockist(s)',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              chemist?.storeName ?? 'Selected Chemist',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chemist Summary Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryDark,
            child: Row(
              children: [
                const Icon(Icons.storefront, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chemist?.storeName ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Locality: ${chemist?.locality ?? ""} • License: ${chemist?.licenseNo ?? ""}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CustomTextField(
              controller: _searchController,
              labelText: 'Search Stockists / Distributors',
              hintText: 'Search by name, code, contact, or city...',
              prefixIcon: Icons.search,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        dcrProvider.filterStockists('');
                        setState(() {});
                      },
                    )
                  : null,
              onChanged: (val) {
                dcrProvider.filterStockists(val);
                setState(() {});
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Available Stockists / Distributors',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$selectedCount Selected',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Select one or more stockists to view available products.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),

          // Stockists List
          Expanded(
            child: dcrProvider.isLoadingStockists
                ? const Center(child: CircularProgressIndicator())
                : dcrProvider.stockistsError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 56,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Failed to load stockists',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dcrProvider.stockistsError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (chemist != null) {
                                    dcrProvider.selectChemist(chemist);
                                  }
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : dcrProvider.availableStockists.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              size: 56,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dcrProvider.stockistSearchQuery.isNotEmpty
                                  ? 'No stockists match your search query'
                                  : 'No stockists available.',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (dcrProvider.stockistSearchQuery.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              const Text(
                                'Try searching by a different name, code or city',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: dcrProvider.availableStockists.length +
                            (dcrProvider.hasMoreStockists ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == dcrProvider.availableStockists.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }

                          final stockist = dcrProvider.availableStockists[index];
                          final isSelected = dcrProvider.selectedStockistIds
                              .contains(stockist.id);

                          return StockistCard(
                            stockist: stockist,
                            isSelected: isSelected,
                            onTap: () {
                              dcrProvider.toggleStockist(stockist.id);
                            },
                          );
                        },
                      ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedCount == 0
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProductCatalogScreen(),
                            ),
                          );
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Proceed to Product Entry ($selectedCount Stockists)'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
