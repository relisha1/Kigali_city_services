import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../models/listing_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'listing_detail_screen.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();
    final auth     = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
            ),
          ),
        ],
      ),
      body: listings.myListings.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: listings.myListings.length,
              itemBuilder: (ctx, i) {
                final item = listings.myListings[i];
                return _MyListingCard(
                  listing: item,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: item),
                    ),
                  ),
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditListingScreen(listing: item),
                    ),
                  ),
                  onDelete: () => _confirmDelete(context, item.id),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark_border, color: AppColors.grey, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No listings yet',
            style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first listing',
            style: TextStyle(color: AppColors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Listing'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyCard,
        title: const Text('Delete Listing', style: TextStyle(color: AppColors.white)),
        content: const Text(
          'Are you sure you want to delete this listing? This cannot be undone.',
          style: TextStyle(color: AppColors.greyLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final error = await context.read<ListingsProvider>().deleteListing(id);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// Individual card with edit/delete
class _MyListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyListingCard({
    required this.listing,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:        AppColors.navyCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        onTap: onTap,
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color:        AppColors.navyLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.place, color: AppColors.gold),
        ),
        title: Text(
          listing.name,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:        AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  listing.category,
                  style: const TextStyle(color: AppColors.gold, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              StarRating(rating: listing.rating, size: 14),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.navyLight,
          icon: const Icon(Icons.more_vert, color: AppColors.grey),
          onSelected: (v) {
            if (v == 'edit')   onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: AppColors.gold, size: 18),
                  SizedBox(width: 10),
                  Text('Edit', style: TextStyle(color: AppColors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                  SizedBox(width: 10),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
