import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';

class ListingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference helper
  CollectionReference get _listingsCol => _db.collection('listings');
  CollectionReference get _reviewsCol  => _db.collection('reviews');

  // Create

  Future<String?> createListing(ListingModel listing) async {
    try {
      await _listingsCol.add(listing.toMap());
      return null; // success
    } catch (e) {
      return 'Failed to create listing: $e';
    }
  }

  // Read

  // Real-time stream of all listings
  Stream<List<ListingModel>> streamAllListings() {
    return _listingsCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ListingModel.fromDoc).toList());
  }

  // Stream listings created by a specific user
  Stream<List<ListingModel>> streamMyListings(String uid) {
    return _listingsCol
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ListingModel.fromDoc).toList());
  }

  // Get a single listing by ID
  Future<ListingModel?> getListing(String id) async {
    try {
      final doc = await _listingsCol.doc(id).get();
      if (doc.exists) return ListingModel.fromDoc(doc);
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update

  Future<String?> updateListing(String id, ListingModel listing) async {
    try {
      await _listingsCol.doc(id).update(listing.toUpdateMap());
      return null;
    } catch (e) {
      return 'Failed to update listing: $e';
    }
  }

  // Delete

  Future<String?> deleteListing(String id) async {
    try {
      await _listingsCol.doc(id).delete();
      return null;
    } catch (e) {
      return 'Failed to delete listing: $e';
    }
  }

  // Reviews

  Stream<List<ReviewModel>> streamReviews(String listingId) {
    return _reviewsCol
        .where('listingId', isEqualTo: listingId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromDoc).toList());
  }

  Future<String?> addReview(ReviewModel review) async {
    try {
      // Save the review
      await _reviewsCol.add(review.toMap());

      // Recalculate average rating using a transaction
      await _db.runTransaction((tx) async {
        final listingRef = _listingsCol.doc(review.listingId);
        final listingSnap = await tx.get(listingRef);

        if (!listingSnap.exists) return;
        final data = listingSnap.data() as Map<String, dynamic>;

        final oldCount  = (data['reviewCount'] ?? 0).toInt();
        final oldRating = (data['rating']      ?? 0.0).toDouble();
        final newCount  = oldCount + 1;
        final newRating = ((oldRating * oldCount) + review.rating) / newCount;

        tx.update(listingRef, {
          'reviewCount': newCount,
          'rating':      double.parse(newRating.toStringAsFixed(1)),
        });
      });

      return null;
    } catch (e) {
      return 'Failed to submit review: $e';
    }
  }

  // Check if the user already reviewed this listing
  Future<bool> hasUserReviewed(String listingId, String userId) async {
    final snap = await _reviewsCol
        .where('listingId', isEqualTo: listingId)
        .where('userId',    isEqualTo: userId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
