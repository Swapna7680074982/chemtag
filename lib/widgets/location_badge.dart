import 'package:flutter/material.dart';
import '../core/utils/location_helper.dart';
import '../core/constants/app_colors.dart';

class LocationBadge extends StatelessWidget {
  final LocationDataResult? location;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const LocationBadge({
    super.key,
    required this.location,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 18,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'GPS Geo-Tagging',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (location != null && !location!.isMockFallback)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Verified GPS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                if (isLoading)
                  const Text(
                    'Acquiring precise satellite coordinates...',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  )
                else if (location != null)
                  Text(
                    'Lat: ${location!.latitude.toStringAsFixed(5)}°, Lng: ${location!.longitude.toStringAsFixed(5)}° (±${location!.accuracyMeters.toStringAsFixed(1)}m)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  )
                else
                  const Text(
                    'Tap refresh to capture current location',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (onRefresh != null && !isLoading)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
              onPressed: onRefresh,
              tooltip: 'Re-acquire Location',
            ),
        ],
      ),
    );
  }
}
