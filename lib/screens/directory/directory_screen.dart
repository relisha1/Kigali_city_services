import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../listings/listing_detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final listings = context.watch<ListingsProvider>();

    final userName = auth.userProfile?.displayName.split(' ').first ?? 'there';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $userName 👋',
                        style: const TextStyle(color: AppColors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Kigali City',
                        style: TextStyle(
                          color:      AppColors.white,
                          fontSize:   22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color:        AppColors.navyCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: AppColors.gold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            //Category chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding:     const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount:   kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = kCategories[i];
                  return CategoryChip(
                    label:      cat,
                    isSelected: listings.selectedCategory == cat,
                    onTap:      () => listings.setCategory(cat),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            //Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                onChanged: listings.setSearch,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText:    'Search for a service…',
                  prefixIcon:  Icon(Icons.search, color: AppColors.grey),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Near You label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Near You',
                    style: TextStyle(
                      color:      AppColors.white,
                      fontSize:   16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${listings.filteredListings.length} found',
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Listings
            Expanded(
              child: listings.isLoading
                  ? _buildShimmer()
                  : listings.filteredListings.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: listings.filteredListings.length,
                          itemBuilder: (ctx, i) {
                            final item = listings.filteredListings[i];
                            return ListingCard(
                              listing: item,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ListingDetailScreen(listing: item),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, color: AppColors.grey, size: 60),
          SizedBox(height: 12),
          Text(
            'No listings found',
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
