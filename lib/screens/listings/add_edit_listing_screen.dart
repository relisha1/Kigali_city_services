import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddEditListingScreen extends StatefulWidget {
  final ListingModel? listing;

  const AddEditListingScreen({super.key, this.listing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _latCtrl     = TextEditingController();
  final _lngCtrl     = TextEditingController();

  String _selectedCategory = kCategories[1];

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final l = widget.listing!;
      _nameCtrl.text    = l.name;
      _addressCtrl.text = l.address;
      _phoneCtrl.text   = l.contactNumber;
      _descCtrl.text    = l.description;
      _latCtrl.text     = l.latitude.toString();
      _lngCtrl.text     = l.longitude.toString();
      _selectedCategory = l.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth     = context.read<AuthProvider>();
    final listings = context.read<ListingsProvider>();

    final newListing = ListingModel(
      id:            _isEditing ? widget.listing!.id : '',
      name:          _nameCtrl.text.trim(),
      category:      _selectedCategory,
      address:       _addressCtrl.text.trim(),
      contactNumber: _phoneCtrl.text.trim(),
      description:   _descCtrl.text.trim(),
      latitude:      double.tryParse(_latCtrl.text) ?? -1.9441,
      longitude:     double.tryParse(_lngCtrl.text) ?? 30.0619,
      createdBy:     auth.firebaseUser!.uid,
      createdAt:     DateTime.now(),
    );

    String? error;
    if (_isEditing) {
      error = await listings.updateListing(widget.listing!.id, newListing);
    } else {
      error = await listings.createListing(newListing);
    }

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Listing updated!' : 'Listing created!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackBtn(),
        title: Text(_isEditing ? 'Edit Listing' : 'Add Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _label('Place / Service Name'),
              _field(_nameCtrl, 'e.g. Kimironko Café', validator: _required),

              const SizedBox(height: 16),

              _label('Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value:       _selectedCategory,
                dropdownColor: AppColors.navyCard,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.navyCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: kCategories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),

              const SizedBox(height: 16),

              _label('Address'),
              _field(_addressCtrl, 'Street name, Kigali', validator: _required),

              const SizedBox(height: 16),

              _label('Contact Number'),
              _field(
                _phoneCtrl,
                '+250 7XX XXX XXX',
                keyboardType: TextInputType.phone,
                validator: _required,
              ),

              const SizedBox(height: 16),

              _label('Description'),
              TextFormField(
                controller: _descCtrl,
                maxLines:   4,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'Describe this place or service…',
                ),
                validator: _required,
              ),

              const SizedBox(height: 16),

              _label('GPS Coordinates'),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _latCtrl,
                      'Latitude',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _lngCtrl,
                      'Longitude',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

             
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Tip: Open Google Maps, long-press a location and copy the coordinates.',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ),

              const SizedBox(height: 32),

              GoldButton(
                label:     _isEditing ? 'Save Changes' : 'Create Listing',
                onPressed: _save,
                isLoading: listings.isLoading,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.greyLight, fontSize: 14),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller:   ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(hintText: hint),
      validator: validator,
    );
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
  }
}
