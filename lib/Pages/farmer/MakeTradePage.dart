import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/farmer/CustomTextField.dart';
import 'package:bukidlink/widgets/farmer/ImagePickerCard.dart';
import 'package:bukidlink/services/ImagePickerService.dart';
import '../../services/TradeService.dart';
import '../../services/cloudinary_service.dart';
import '../../models/TradeModels.dart';

class MakeTradePage extends StatefulWidget {
  // Update 1: Accept listing for Edit Mode
  final TradeListing? listing;

  const MakeTradePage({Key? key, this.listing}) : super(key: key);

  @override
  _MakeTradePageState createState() => _MakeTradePageState();
}

class _MakeTradePageState extends State<MakeTradePage> {
  final TradeService _tradeService = TradeService();
  String? _imagePath;
  final ImagePickerService _imagePickerService = ImagePickerService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descController = TextEditingController(); // Description Controller
  final _prefController = TextEditingController();

  List<String> _preferredTrades = [];
  bool _isLoading = false;
  bool _isEditing = false; // Update 2: State flag

  @override
  void initState() {
    super.initState();
    // Update 3: Check if editing and populate fields
    if (widget.listing != null) {
      _isEditing = true;
      _nameController.text = widget.listing!.name;
      _quantityController.text = widget.listing!.quantity;
      _descController.text = widget.listing!.description;
      _preferredTrades = List.from(widget.listing!.preferredTrades);
      _imagePath = widget.listing!.image.isNotEmpty
          ? widget.listing!.image
          : null;
    }
  }

  Future<void> _handleImagePicker() async {
    HapticFeedback.lightImpact();
    final String? path = await _imagePickerService.showImageSourceBottomSheet(
      context,
    );
    if (path != null) setState(() => _imagePath = path);
  }

  void _addPref() {
    if (_prefController.text.isNotEmpty) {
      setState(() {
        _preferredTrades.add(_prefController.text.trim());
        _prefController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_isEditing ? 'Confirm update' : 'Confirm post'),
        content: Text(
          _isEditing
              ? 'Update this trade listing? Changes will be saved.'
              : 'Post this trade listing? Other farmers will see it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Determine Image Path (New selection ?? Existing listing image ?? Empty)
      String imagePath = _imagePath ?? (widget.listing?.image ?? '');

      // If a local file path was chosen (not a remote URL), upload it to Cloudinary
      if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
        try {
          final uploadedUrl = await CloudinaryService().uploadFile(
            File(imagePath),
          );
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            imagePath = uploadedUrl;
          }
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      final listingData = TradeListing(
        id: _isEditing ? widget.listing!.id : '', // Use existing ID if editing
        name: _nameController.text,
        quantity: _quantityController.text,
        description: _descController.text,
        preferredTrades: _preferredTrades,
        image: imagePath,
        // Update 5: Preserve farmerId if editing, let service handle if new
        farmerId: _isEditing ? widget.listing!.farmerId : '',
        offersCount: _isEditing ? widget.listing!.offersCount : 0,
        createdAt: _isEditing ? widget.listing!.createdAt : DateTime.now(),
      );

      // Update 6: Call Update or Create based on mode
      if (_isEditing) {
        await _tradeService.updateListing(listingData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trade updated'),
            backgroundColor: Colors.green[600],
          ),
        );
      } else {
        await _tradeService.createListing(listingData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trade posted'),
            backgroundColor: Colors.green[600],
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // No inline ImageProvider logic needed; ImagePickerCard handles imagePath

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.HEADER_GRADIENT_START,
                AppColors.HEADER_GRADIENT_END,
              ],
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isEditing ? Icons.edit : Icons.swap_horiz_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _isEditing ? 'Edit Trade' : 'Make a Trade',
              style: const TextStyle(
                fontFamily: AppTextStyles.FONT_FAMILY,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF5F5F5),
                  const Color(0xFFE8F5E9).withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            'Basic Information',
                            Icons.info_outline,
                          ),
                          const SizedBox(height: 16),

                          _buildCard(
                            child: Column(
                              children: [
                                CustomTextField(
                                  label: 'Item Name',
                                  hint: 'e.g., Fresh Mango',
                                  controller: _nameController,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Please enter item name'
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  label: 'Quantity',
                                  hint: 'e.g., 20',
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Please enter quantity';
                                    if (int.tryParse(v.trim()) == null)
                                      return 'Enter a valid number';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  label: 'Description',
                                  hint: 'Details about the product',
                                  controller: _descController,
                                  maxLines: 4,
                                  maxLength: 500,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildSectionHeader(
                            'Product Image',
                            Icons.image_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload a clear image of the item',
                                  style: AppTextStyles.BODY_MEDIUM.copyWith(
                                    color: AppColors.TEXT_SECONDARY,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ImagePickerCard(
                                  imagePath: _imagePath,
                                  onTap: _handleImagePicker,
                                  onRemove: _imagePath != null
                                      ? () => setState(() => _imagePath = null)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildSectionHeader(
                            'Preferred Trades',
                            Icons.favorite_border,
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Label above so the add button aligns with the input box
                                Text(
                                  'Preferred Item',
                                  style: AppTextStyles.FORM_LABEL.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.DARK_TEXT,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _prefController,
                                        decoration: InputDecoration(
                                          hintText: 'e.g., Rice, Eggs',
                                          hintStyle: AppTextStyles
                                              .TEXT_FIELD_HINT
                                              .copyWith(
                                                fontSize: 14,
                                                color: AppColors.HINT_TEXT_GREY
                                                    .withOpacity(0.7),
                                              ),
                                          filled: true,
                                          fillColor: AppColors.BACKGROUND_WHITE,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.BORDER_GREY
                                                  .withOpacity(0.2),
                                              width: 1.5,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                          counterText: '',
                                        ),
                                        style: AppTextStyles.BODY_MEDIUM
                                            .copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      height: 56,
                                      width: 56,
                                      child: ElevatedButton(
                                        onPressed: _addPref,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.ACCENT_LIME,
                                          foregroundColor: AppColors.DARK_TEXT,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Icon(Icons.add, size: 28),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    spacing: 8,
                                    children: _preferredTrades
                                        .map(
                                          (t) => Chip(
                                            label: Text(t),
                                            onDeleted: () => setState(
                                              () => _preferredTrades.remove(t),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Press the + button to add preferred items',
                                  style: AppTextStyles.BODY_MEDIUM.copyWith(
                                    color: AppColors.TEXT_SECONDARY,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.ACCENT_LIME.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.ACCENT_LIME,
                                  foregroundColor: AppColors.DARK_TEXT,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isEditing
                                          ? Icons.edit
                                          : Icons.check_circle_outline,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isEditing
                                          ? 'Update Trade'
                                          : 'Post Trade',
                                      style: AppTextStyles.PRIMARY_BUTTON_TEXT
                                          .copyWith(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen.withOpacity(0.15),
                AppColors.HEADER_GRADIENT_END.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: AppColors.primaryGreen),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.FORM_LABEL.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E7D32),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // Helper method to build card containers
  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
