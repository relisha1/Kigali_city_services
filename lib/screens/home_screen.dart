import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../utils/app_theme.dart';
import 'directory/directory_screen.dart';
import 'listings/my_listings_screen.dart';
import 'map/map_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DirectoryScreen(),
    MyListingsScreen(),
    MapScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    final listingsProvider = context.read<ListingsProvider>();
    final authProvider = context.read<AuthProvider>();

    // Start listening immediately
    listingsProvider.subscribeAll();

    if (authProvider.firebaseUser != null) {
      listingsProvider.subscribeMyListings(authProvider.firebaseUser!.uid);
    }
  }

  Future<void> _refresh() async {
    final listingsProvider = context.read<ListingsProvider>();
    final authProvider = context.read<AuthProvider>();

    listingsProvider.subscribeAll();
    if (authProvider.firebaseUser != null) {
      listingsProvider.subscribeMyListings(authProvider.firebaseUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.gold,
        backgroundColor: AppColors.navyCard,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          // Re-subscribe every time user switches tabs
          _refresh();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}