import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/dcr_provider.dart';
import '../widgets/product_item_card.dart';
import '../widgets/custom_text_field.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import 'dcr_summary_dialog.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
              '${dcrProvider.selectedChemist?.storeName ?? "Chemist"} • ${dcrProvider.selectedStockistsList.map((s) => s.code).join(", ")}',
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
                  labelText: 'Search Product Catalog',
                  hintText: 'Search product name, SKU, or formulation...',
                  prefixIcon: Icons.search,
                  onChanged: (val) => dcrProvider.filterProducts(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Product List
          Expanded(
            child: dcrProvider.isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
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
                          Text(
                            '${dcrProvider.totalItemsCount} Products • ${dcrProvider.totalUnitsQuantity} Units',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppFormatters.formatCurrency(
                                dcrProvider.totalEstimatedValue),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: dcrProvider.totalItemsCount == 0
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const DcrSummaryDialog(),
                                );
                              },
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text('Review'),
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
