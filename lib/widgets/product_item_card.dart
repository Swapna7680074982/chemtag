import 'package:flutter/material.dart';
import '../models/product.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/stockist.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';

class ProductItemCard extends StatelessWidget {
  final Product product;
  final List<Stockist> availableSelectedStockists;
  final int Function(String stockistId) getQuantity;
  final void Function(String stockistId, int quantity) onQuantityChanged;

  const ProductItemCard({
    super.key,
    required this.product,
    required this.availableSelectedStockists,
    required this.getQuantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Check if any stockist has quantity > 0
    bool hasQuantity = availableSelectedStockists.any((s) => getQuantity(s.id) > 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasQuantity ? AppColors.primary : AppColors.border,
          width: hasQuantity ? 1.8 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  product.skuCode,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (product.inStock)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'In Stock',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pack: ${product.packSize}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PTR (Retailer Price)',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      AppFormatters.formatCurrency(product.ptr),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MRP',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      AppFormatters.formatCurrency(product.mrp),
                      style: const TextStyle(
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Select Quantities by Distributor:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...availableSelectedStockists.map((stockist) {
              final qty = getQuantity(stockist.id);
              final isItemQty = qty > 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${stockist.name} (${stockist.code})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quantity Counter Widget per stockist
                    _QuantityCounter(
                      quantity: qty,
                      onQuantityChanged: (newQty) {
                        onQuantityChanged(stockist.id, newQty);
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _QuantityCounter extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _QuantityCounter({
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  State<_QuantityCounter> createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<_QuantityCounter> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.quantity > 0 ? widget.quantity.toString() : '');
  }

  @override
  void didUpdateWidget(covariant _QuantityCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      final text = widget.quantity > 0 ? widget.quantity.toString() : '';
      if (_controller.text != text) {
        _controller.text = text;
        _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasQuantity = widget.quantity > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            color: hasQuantity ? AppColors.danger : AppColors.textMuted,
            onPressed: hasQuantity
                ? () {
                    widget.onQuantityChanged(widget.quantity - 1);
                  }
                : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 36,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
              ),
              onChanged: (val) {
                int? parsed = int.tryParse(val);
                widget.onQuantityChanged(parsed ?? 0);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            color: AppColors.primary,
            onPressed: () {
              widget.onQuantityChanged(widget.quantity + 1);
            },
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
