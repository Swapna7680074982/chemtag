import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/dcr_provider.dart';
import '../models/dcr_submission.dart';
import '../models/stockist.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';

class DcrHistoryScreen extends StatefulWidget {
  const DcrHistoryScreen({super.key});

  @override
  State<DcrHistoryScreen> createState() => _DcrHistoryScreenState();
}

class _DcrHistoryScreenState extends State<DcrHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dcrProvider = Provider.of<DcrProvider>(context, listen: false);
      dcrProvider.fetchDcrHistory();
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
      dcrProvider.loadMoreHistory();
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
        title: Text(
          'DCR Submissions & Geo-Logs',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                dcrProvider.filterHistory(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by chemist, stockist, product...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          dcrProvider.filterHistory('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: dcrProvider.isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : dcrProvider.dcrHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.history_toggle_off_rounded,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dcrProvider.historySearchQuery.isNotEmpty
                                  ? 'No Matching Submissions Found'
                                  : 'No DCR Submissions Logged Yet',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dcrProvider.historySearchQuery.isNotEmpty
                                  ? 'Try refining your search query.'
                                  : 'Start a new chemist DCR call from the home dashboard to record call entries.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: dcrProvider.dcrHistory.length +
                            (dcrProvider.hasMoreHistory ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == dcrProvider.dcrHistory.length) {
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

                          final submission = dcrProvider.dcrHistory[index];
                          return _buildSubmissionCard(context, submission);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, DcrSubmission submission) {
    // Group products by their stockist name
    final Map<String, List<DcrItem>> stockistProducts = {};
    for (var stockist in submission.selectedStockists) {
      stockistProducts[stockist.name] = [];
    }

    final List<DcrItem> unassignedProducts = [];
    for (var item in submission.items) {
      final sName = item.stockistName.trim();
      if (sName.isNotEmpty && stockistProducts.containsKey(sName)) {
        stockistProducts[sName]!.add(item);
      } else {
        // Fallback: try to find a stockist with matching name in selectedStockists
        final match = submission.selectedStockists.firstWhere(
          (s) => s.name.toLowerCase() == sName.toLowerCase(),
          orElse: () => Stockist(id: '', name: ''),
        );
        if (match.name.isNotEmpty) {
          stockistProducts[match.name]!.add(item);
        } else if (submission.selectedStockists.length == 1) {
          // If only one stockist was selected, assign all items to it
          stockistProducts[submission.selectedStockists.first.name]!.add(item);
        } else {
          unassignedProducts.add(item);
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chemist name
            Text(
              submission.chemist.storeName,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Metadata Row: Order ID and Submission Date & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                    child: Text(
                      submission.id,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppFormatters.formatDateTime(submission.submittedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Latitude and Longitude
            Row(
              children: [
                const Icon(
                  Icons.my_location,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${submission.latitude.toStringAsFixed(5)}°, ${submission.longitude.toStringAsFixed(5)}°',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1, color: AppColors.border),

            // Selected Stockists and products
            ...stockistProducts.entries.map((entry) {
              final stockistName = entry.key;
              final items = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stockist Name
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            stockistName,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Products list
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'No products selected',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    else
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: item.productName.trim(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const TextSpan(text: '   '),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.primaryBorder),
                                          ),
                                          child: Text(
                                            '${item.quantity} Qty',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              );
            }),

            // Unassigned products if any
            if (unassignedProducts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Other Products',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              ...unassignedProducts.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: item.productName.trim(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const TextSpan(text: '   '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.primaryBorder),
                                  ),
                                  child: Text(
                                    '${item.quantity} Qty',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
