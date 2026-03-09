import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';
import '../services/listing_service.dart';

class ListingsProvider extends ChangeNotifier {
  final ListingService _service = ListingService();

  List<ListingModel> _allListings    = [];
  List<ListingModel> _myListings     = [];
  List<ReviewModel>  _currentReviews = [];

  String  _searchQuery      = '';
  String  _selectedCategory = 'All';
  bool    _isLoading        = false;
  String? _errorMessage;

  StreamSubscription? _allListingsSub;
  StreamSubscription? _myListingsSub;
  StreamSubscription? _reviewsSub;

  // Getters

  List<ListingModel> get myListings     => _myListings;
  List<ListingModel> get allListings    => _allListings;
  List<ReviewModel>  get currentReviews => _currentReviews;
  bool               get isLoading      => _isLoading;
  String?            get errorMessage   => _errorMessage;
  String             get searchQuery    => _searchQuery;
  String             get selectedCategory => _selectedCategory;

  // Filtered list used by the directory screen
  List<ListingModel> get filteredListings {
    var result = _allListings;

    if (_selectedCategory != 'All') {
      result = result.where((l) => l.category == _selectedCategory).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((l) =>
        l.name.toLowerCase().contains(q) ||
        l.address.toLowerCase().contains(q) ||
        l.category.toLowerCase().contains(q)
      ).toList();
    }

    return result;
  }

  // Subscribe to all listings stream

  void subscribeAll() {
    _allListingsSub?.cancel();
    _allListingsSub = _service.streamAllListings().listen(
      (listings) {
        _allListings = listings;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load listings.';
        notifyListeners();
      },
    );
  }

  //Subscribe to my listings stream
  void subscribeMyListings(String uid) {
    _myListingsSub?.cancel();
    _myListingsSub = _service.streamMyListings(uid).listen(
      (listings) {
        _myListings = listings;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load your listings.';
        notifyListeners();
      },
    );
  }

  // Subscribe to reviews
  void subscribeReviews(String listingId) {
    _reviewsSub?.cancel();
    _reviewsSub = _service.streamReviews(listingId).listen(
      (reviews) {
        _currentReviews = reviews;
        notifyListeners();
      },
    );
  }

  void unsubscribeReviews() {
    _reviewsSub?.cancel();
    _currentReviews = [];
  }

  // Search / Filter

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // CRUD

  Future<String?> createListing(ListingModel listing) async {
    _isLoading = true;
    notifyListeners();
    final error = await _service.createListing(listing);
    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> updateListing(String id, ListingModel listing) async {
    _isLoading = true;
    notifyListeners();
    final error = await _service.updateListing(id, listing);
    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<String?> deleteListing(String id) async {
    final error = await _service.deleteListing(id);
    return error;
  }

  Future<String?> addReview(ReviewModel review) async {
    return await _service.addReview(review);
  }

  Future<bool> hasUserReviewed(String listingId, String userId) {
    return _service.hasUserReviewed(listingId, userId);
  }

  // Cleanup
  @override
  void dispose() {
    _allListingsSub?.cancel();
    _myListingsSub?.cancel();
    _reviewsSub?.cancel();
    super.dispose();
  }
}
