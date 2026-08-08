import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/dcr_provider.dart';
import '../widgets/chemist_card.dart';
import '../widgets/custom_text_field.dart';
import '../core/constants/app_colors.dart';
import 'stockist_selection_screen.dart';

class ChemistSelectionScreen extends StatelessWidget {
  const ChemistSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dcrProvider = Provider.of<DcrProvider>(context);
    final tseId = authProvider.currentUser?.employeeId ?? 'TSE-10042';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 1 of 4: Select Chemist',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Mapped Chemists for TSE: $tseId',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input Field
            CustomTextField(
              labelText: 'Search Mapped Chemists',
              hintText: 'Search by store name, owner, locality, or DL No...',
              prefixIcon: Icons.search,
              onChanged: (val) => dcrProvider.filterChemists(val),
            ),
            const SizedBox(height: 16),

            // Header info bar
            Row(
              children: [
                Text(
                  'Showing ${dcrProvider.chemists.length} Mapped Chemists',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.tune, size: 16, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 12),

            // Chemists List
            Expanded(
              child: dcrProvider.isLoadingChemists
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : dcrProvider.chemists.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.storefront_outlined,
                                size: 56,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No chemists match your search query',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try searching by a different name or locality',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: dcrProvider.chemists.length,
                          itemBuilder: (context, index) {
                            final chemist = dcrProvider.chemists[index];
                            final isSelected =
                                dcrProvider.selectedChemist?.id == chemist.id;

                            return ChemistCard(
                              chemist: chemist,
                              isSelected: isSelected,
                              onTap: () async {
                                await dcrProvider.selectChemist(chemist);
                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const StockistSelectionScreen(),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
