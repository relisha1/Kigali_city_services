import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/listings_provider.dart';
import '../../models/listing_model.dart';
import '../../utils/app_theme.dart';
import '../listings/listing_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // Default camera: center of Kigali
  static const _kigaliCenter = CameraPosition(
    target: LatLng(-1.9441, 30.0619),
    zoom: 13,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<ListingModel> listings) {
    return listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title:   listing.name,
          snippet: listing.category,
          onTap:   () => _openDetail(listing),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    }).toSet();
  }

  void _openDetail(ListingModel listing) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>().allListings;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kigaliCenter,
            onMapCreated: (c) => _mapController = c,
            markers: _buildMarkers(listings),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Header overlay
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: AppColors.navy.withOpacity(0.85),
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 12,
                20,
                12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Map View',
                    style: TextStyle(
                      color:      AppColors.white,
                      fontSize:   18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:        AppColors.gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${listings.length} places',
                      style: const TextStyle(
                        color:      AppColors.navy,
                        fontWeight: FontWeight.w600,
                        fontSize:   13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Zoom to Kigali button
          Positioned(
            bottom: 24, right: 16,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.navyCard,
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(_kigaliCenter),
                );
              },
              child: const Icon(Icons.my_location, color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}
