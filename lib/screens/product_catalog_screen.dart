import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/dcr_provider.dart';
import '../widgets/product_item_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../core/constants/app_colors.dart';
import 'dcr_summary_dialog.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    final dcrProvider = Provider.of<DcrProvider>(context, listen: false);
    _searchController = TextEditingController(text: dcrProvider.productSearchQuery);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dcrProvider.loadProductsForSelectedStockists();
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
      dcrProvider.loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dcrProvider = Provider.of<DcrProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 3 of 4: Product Order',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${dcrProvider.selectedChemist?.chemistName ?? "Chemist"}',
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
          // Search Header Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _searchController,
                  labelText: 'Search Product Catalog',
                  hintText: 'Search product name, SKU, or formulation...',
                  prefixIcon: Icons.search,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            dcrProvider.filterProducts('');
                            setState(() {});
                          },
                        )
                      : null,
                  onChanged: (val) {
                    dcrProvider.filterProducts(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Product List
          Expanded(
            child: dcrProvider.isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : dcrProvider.productsError != null
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
                                'Failed to load products',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dcrProvider.productsError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 24),
                              GradientButton(
                                onPressed: () =>
                                    dcrProvider.loadProductsForSelectedStockists(),
                                icon: Icons.refresh,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : dcrProvider.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 52,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No products match the selected stockists',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try modifying stockist selection or search query',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: dcrProvider.products.length +
                            (dcrProvider.hasMoreProducts ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == dcrProvider.products.length) {
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

                          final product = dcrProvider.products[index];
                          final availableSelectedStockists = dcrProvider.selectedStockistsList;

                          return ProductItemCard(
                            product: product,
                            availableSelectedStockists: availableSelectedStockists,
                            getQuantity: (stockistId) =>
                                dcrProvider.getQuantity(product.id, stockistId),
                            onQuantityChanged: (stockistId, qty) {
                              dcrProvider.updateQuantity(
                                  product.id, stockistId, qty);
                            },
                          );
                        },
                      ),
          ),

          // Sticky Bottom Cart Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Order Summary',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dcrProvider.totalItemsCount} Products • ${dcrProvider.totalUnitsQuantity} Units',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GradientButton(
                        onPressed: dcrProvider.totalItemsCount == 0
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const DcrSummaryDialog(),
                                );
                              },
                        icon: Icons.rate_review_outlined,
                        child: const Text('Review'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
