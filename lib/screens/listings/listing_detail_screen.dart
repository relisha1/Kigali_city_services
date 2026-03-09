import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/listing_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  double _myRating  = 0;
  String _myComment = '';
  bool   _submitting = false;

  @override
  void initState() {
    super.initState();
    // Start listening to reviews for this listing
    context.read<ListingsProvider>().subscribeReviews(widget.listing.id);
  }

  @override
  void dispose() {
    context.read<ListingsProvider>().unsubscribeReviews();
    super.dispose();
  }

  Future<void> _openDirections() async {
    final lat = widget.listing.latitude;
    final lng = widget.listing.longitude;
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submitReview() async {
    if (_myRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating.')),
      );
      return;
    }

    final auth     = context.read<AuthProvider>();
    final listings = context.read<ListingsProvider>();

    // Check if already reviewed
    final alreadyReviewed = await listings.hasUserReviewed(
      widget.listing.id,
      auth.firebaseUser!.uid,
    );

    if (alreadyReviewed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already reviewed this place.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    final review = ReviewModel(
      id:        '',
      listingId: widget.listing.id,
      userId:    auth.firebaseUser!.uid,
      userName:  auth.userProfile?.displayName ?? 'Anonymous',
      rating:    _myRating,
      comment:   _myComment,
      createdAt: DateTime.now(),
    );

    final error = await listings.addReview(review);

    if (mounted) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Review submitted!'),
          backgroundColor: error != null ? AppColors.error : AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final reviews = context.watch<ListingsProvider>().currentReviews;

    return Scaffold(
      appBar: AppBar(
        leading: const BackBtn(),
        title: Text(listing.name, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Map preview
            SizedBox(
              height: 220,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(listing.latitude, listing.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('place'),
                    position: LatLng(listing.latitude, listing.longitude),
                    infoWindow: InfoWindow(title: listing.name),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),

            // Info card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        AppColors.navyCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    style: const TextStyle(
                      color:      AppColors.white,
                      fontSize:   20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StarRating(rating: listing.rating, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${listing.category}  ·  ${listing.rating.toStringAsFixed(1)}',
                        style: const TextStyle(color: AppColors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    listing.description,
                    style: const TextStyle(color: AppColors.greyLight, height: 1.5),
                  ),
                  const Divider(color: AppColors.navyLight, height: 24),
                  _infoRow(Icons.location_on_outlined, listing.address),
                  const SizedBox(height: 8),
                  _infoRow(Icons.phone_outlined, listing.contactNumber),
                ],
              ),
            ),

            // Navigate button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GoldButton(
                label:     'Get Directions',
                onPressed: _openDirections,
              ),
            ),

            const SizedBox(height: 24),

            //Reviews section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          color:      AppColors.white,
                          fontSize:   17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${listing.reviewCount} reviews',
                        style: const TextStyle(color: AppColors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Average rating display
                  Row(
                    children: [
                      Text(
                        listing.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color:      AppColors.gold,
                          fontSize:   36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StarRating(rating: listing.rating, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            '${listing.reviewCount} reviews',
                            style: const TextStyle(color: AppColors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // List of reviews
                  ...reviews.map((r) => _ReviewTile(review: r)),

                  const SizedBox(height: 20),

                  // Write a review
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:        AppColors.navyCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rate this service',
                          style: TextStyle(
                            color:      AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RatingBar.builder(
                          initialRating: _myRating,
                          minRating:  1,
                          itemCount:  5,
                          itemSize:   32,
                          itemBuilder: (_, __) =>
                              const Icon(Icons.star, color: AppColors.gold),
                          onRatingUpdate: (r) => setState(() => _myRating = r),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          onChanged: (v) => _myComment = v,
                          maxLines: 3,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(
                            hintText: 'Share your experience…',
                          ),
                        ),
                        const SizedBox(height: 12),
                        GoldButton(
                          label:     'Submit Review',
                          onPressed: _submitReview,
                          isLoading: _submitting,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: AppColors.greyLight)),
        ),
      ],
    );
  }
}

// Individual review tile 
class _ReviewTile extends StatelessWidget {
  final ReviewModel review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTime(review.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.navyCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
              Text(timeAgo, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          StarRating(rating: review.rating),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${review.comment}"',
              style: const TextStyle(color: AppColors.greyLight, fontStyle: FontStyle.italic, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 30)  return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}
