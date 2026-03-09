import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/listing_model.dart';
import '../utils/app_theme.dart';

// Star rating display
class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating:     rating,
      itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.gold),
      itemCount:  5,
      itemSize:   size,
    );
  }
}

// Category chip
class CategoryChip extends StatelessWidget {
  final String label;
  final bool   isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:        isSelected ? AppColors.gold : AppColors.navyCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.navyLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      isSelected ? AppColors.navy : AppColors.white,
            fontSize:   13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Listing card used in directory and my‑listings
class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  final double?      distanceKm;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.navyCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color:        AppColors.navyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _categoryIcon(listing.category),
                color: AppColors.gold,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Name + stars
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    style: const TextStyle(
                      color:      AppColors.white,
                      fontSize:   15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StarRating(rating: listing.rating),
                      const SizedBox(width: 6),
                      Text(
                        listing.rating.toStringAsFixed(1),
                        style: const TextStyle(color: AppColors.gold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Distance
            if (distanceKm != null)
              Text(
                listing.distanceText(distanceKm!),
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'cafés':          return Icons.coffee;
      case 'restaurants':    return Icons.restaurant;
      case 'hospitals':      return Icons.local_hospital;
      case 'police stations': return Icons.local_police;
      case 'libraries':      return Icons.library_books;
      case 'parks':          return Icons.park;
      case 'tourist attractions': return Icons.photo_camera;
      case 'pharmacies':     return Icons.local_pharmacy;
      default:               return Icons.place;
    }
  }
}

// Loading shimmer card
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.navyCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color:        AppColors.navyLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 140, color: AppColors.navyLight),
                const SizedBox(height: 8),
                Container(height: 12, width: 100, color: AppColors.navyLight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Gold filled button
class GoldButton extends StatelessWidget {
  final String    label;
  final VoidCallback? onPressed;
  final bool      isLoading;

  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.navy,
                  strokeWidth: 2,
                ),
              )
            : Text(label),
      ),
    );
  }
}

// nav back button in appbar
class BackBtn extends StatelessWidget {
  const BackBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
      onPressed: () => Navigator.pop(context),
    );
  }
}
