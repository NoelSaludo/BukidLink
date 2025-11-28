import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/farmer/CustomTextField.dart';
import 'package:bukidlink/widgets/farmer/ImagePickerCard.dart';
import 'package:bukidlink/widgets/farmer/CategorySelector.dart';
import 'package:bukidlink/widgets/farmer/UnitSelector.dart';
import 'package:bukidlink/services/ImagePickerService.dart';
import 'package:bukidlink/services/FarmService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/services/cloudinary_service.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/models/Farm.dart';

// Farmer Sell Product Page
class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final FarmService _farmService = FarmService();

  // Form controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  // Static SRP value for demo
  static const double _srp = 100.0;
  String? _priceAlert;

  // Form state
  String? _productImagePath;
  String? _selectedCategory;
  String? _selectedUnit;
  String? _customUnit;
  bool _isLoading = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_checkPriceAgainstSRP);
  }

  void _checkPriceAgainstSRP() {
    final value = _priceController.text;
    final price = double.tryParse(value);
    if (price == null) {
      setState(() {
        _priceAlert = null;
      });
      return;
    }
    if (price > _srp * 1.2) {
      setState(() {
        _priceAlert = 'The price is too high compared to the SRP.';
      });
    } else if (price < _srp * 0.8) {
      setState(() {
        _priceAlert = 'The price is too low compared to the SRP.';
      });
    } else {
      setState(() {
        _priceAlert = null;
      });
    }
  }

  Future<void> _handleImagePicker() async {
    HapticFeedback.lightImpact();
    final String? imagePath = await _imagePickerService
        .showImageSourceBottomSheet(context);

    if (imagePath != null) {
      setState(() {
        _productImagePath = imagePath;
      });
    }
  }

  void _handleRemoveImage() {
    HapticFeedback.lightImpact();
    setState(() {
      _productImagePath = null;
    });
  }

  void _handleCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _handleUnitSelected(String unit) {
    setState(() {
      _selectedUnit = unit;
      if (unit != 'Other') {
        _customUnit = null;
      }
    });
  }

  void _handleCustomUnitChanged(String value) {
    setState(() {
      _customUnit = value;
    });
  }

  String? _validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter product name';
    }
    if (value.length < 2) {
      return 'Product name must be at least 2 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter product description';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter price';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  Widget _buildSRPAlert() {
    if (_priceAlert == null) return const SizedBox.shrink();
    // Extract if alert is high or low
    final isHigh = _priceAlert!.contains('too high');
    final isLow = _priceAlert!.contains('too low');
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.ERROR_RED, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: isHigh
                        ? 'The price is too high compared to the SRP ('
                        : isLow
                        ? 'The price is too low compared to the SRP ('
                        : '',
                    style: AppTextStyles.BODY_MEDIUM.copyWith(
                      color: AppColors.ERROR_RED,
                      fontSize: 13,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Text(
                      '₱',
                      style: AppTextStyles.PESO_SYMBOL.copyWith(
                        color: AppColors.ERROR_RED,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: '${_srp.toStringAsFixed(2)})',
                    style: AppTextStyles.BODY_MEDIUM.copyWith(
                      color: AppColors.ERROR_RED,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter stock';
    }
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Please enter a valid number';
    }
    if (stock <= 0) {
      return 'Stock must be greater than 0';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    HapticFeedback.mediumImpact();

    // Validate image - removed for now not implemented yet :)
    /* if (_productImagePath == null) {
      _showErrorDialog('Please add a product image');
      return;
    } */

    // Validate category
    if (_selectedCategory == null) {
      _showErrorDialog('Please select a category');
      return;
    }

    // Validate unit
    if (_selectedUnit == null) {
      _showErrorDialog('Please select how the product is sold');
      return;
    }

    // Validate custom unit if "Other" is selected
    if (_selectedUnit == 'Other' &&
        (_customUnit == null || _customUnit!.trim().isEmpty)) {
      _showErrorDialog('Please enter a custom unit');
      return;
    }

    // Validate form fields
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = UserService().getCurrentUser();
        if (user == null) {
          throw Exception('No user logged in');
        }

        // Use FarmService to get the farm for the user
        debugPrint('Fetching farm for user: ${user.id}');
        debugPrint('Farm ID: ${user.farmId?.id}');
        final Farm? farm = await _farmService.getFarmForUser(user);
        if (farm == null) {
          throw Exception('User has no associated farm');
        }

        final double price = double.parse(_priceController.text);
        final int stockCount = int.parse(_stockController.text);
        final String availability = stockCount > 0
            ? 'In Stock'
            : 'Out of Stock';
        final String unit = _selectedUnit == 'Other'
            ? _customUnit!
            : _selectedUnit!;

        // Note: Farm name might need to be fetched if not available in Product model or user context
        // Assuming farm.name is available
        final String farmName = farm.name;

        // Create Product object
        // Prepare image path: if already a remote URL use it, otherwise upload local file to Cloudinary.
        String imageUrl = '';
        if (_productImagePath != null && _productImagePath!.isNotEmpty) {
          if (_productImagePath!.startsWith('http://') ||
              _productImagePath!.startsWith('https://')) {
            imageUrl = _productImagePath!;
          } else {
            // Local path -> upload to Cloudinary
            try {
              final uploaded = await CloudinaryService().uploadFile(
                File(_productImagePath!),
              );
              if (uploaded != null && uploaded.isNotEmpty) imageUrl = uploaded;
            } catch (e) {
              debugPrint('Product image upload failed: $e');
              throw Exception('Failed to upload product image');
            }
          }
        }

        final product = Product(
          id: '', // Generated by Firestore
          name: _productNameController.text,
          farmName: farmName,
          farmId: farm.id, // Store as String ID
          imagePath: imageUrl,
          category: _selectedCategory!,
          price: price,
          description: _descriptionController.text,
          rating: 0.0,
          unit: unit,
          reviewCount: 0,
          availability: availability,
          stockCount: stockCount,
          reviews: null,
        );

        await _farmService.addProductToFarm(product);

        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Failed to add product: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.ERROR_RED.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.ERROR_RED,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops!',
              style: AppTextStyles.FORM_LABEL.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.BODY_MEDIUM.copyWith(
                fontSize: 15,
                color: AppColors.TEXT_SECONDARY,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ERROR_RED,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  fontFamily: AppTextStyles.FONT_FAMILY,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.SUCCESS_GREEN.withOpacity(0.2),
                    AppColors.SUCCESS_GREEN.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.SUCCESS_GREEN.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppColors.SUCCESS_GREEN,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success!',
              style: TextStyle(
                fontFamily: AppTextStyles.FONT_FAMILY,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.DARK_TEXT,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Product Added',
              style: AppTextStyles.FORM_LABEL.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.SUCCESS_GREEN,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your product "${_productNameController.text}" has been successfully added to your store!',
              style: AppTextStyles.BODY_MEDIUM.copyWith(
                fontSize: 14,
                color: AppColors.TEXT_SECONDARY,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.SUCCESS_GREEN,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Back to Store',
                style: TextStyle(
                  fontFamily: AppTextStyles.FONT_FAMILY,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
              child: const Icon(
                Icons.add_business_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sell Product',
              style: TextStyle(
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
                // Form content with improved spacing
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
                          // Section: Basic Information
                          _buildSectionHeader(
                            'Basic Information',
                            Icons.info_outline,
                          ),
                          const SizedBox(height: 16),

                          _buildCard(
                            child: Column(
                              children: [
                                CustomTextField(
                                  label: 'Product Name',
                                  hint: 'e.g., Fresh Tomatoes',
                                  controller: _productNameController,
                                  validator: _validateProductName,
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  label: 'Product Description',
                                  hint: 'Describe your product in detail',
                                  controller: _descriptionController,
                                  maxLines: 4,
                                  maxLength: 500,
                                  validator: _validateDescription,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section: Product Image
                          _buildSectionHeader(
                            'Product Image',
                            Icons.image_outlined,
                          ),
                          const SizedBox(height: 16),

                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload a clear image of your product',
                                  style: AppTextStyles.BODY_MEDIUM.copyWith(
                                    color: AppColors.TEXT_SECONDARY,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ImagePickerCard(
                                  imagePath: _productImagePath,
                                  onTap: _handleImagePicker,
                                  onRemove: _productImagePath != null
                                      ? _handleRemoveImage
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section: Category
                          _buildSectionHeader(
                            'Category',
                            Icons.category_outlined,
                          ),
                          const SizedBox(height: 16),

                          _buildCard(
                            child: CategorySelector(
                              selectedCategory: _selectedCategory,
                              onCategorySelected: _handleCategorySelected,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section: Pricing & Stock
                          _buildSectionHeader(
                            'Pricing & Stock',
                            Icons.monetization_on_outlined,
                          ),
                          const SizedBox(height: 16),

                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Price',
                                        hint: '0.00',
                                        controller: _priceController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        validator: _validatePrice,
                                        prefix: Text(
                                          '₱',
                                          style: AppTextStyles.PESO_SYMBOL
                                              .copyWith(
                                                fontSize: 18,
                                                color: AppColors.primaryGreen,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Stock',
                                        hint: '0',
                                        controller: _stockController,
                                        keyboardType: TextInputType.number,
                                        validator: _validateStock,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildSRPAlert(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section: Unit of Sale
                          _buildSectionHeader(
                            'Unit of Sale',
                            Icons.shopping_basket_outlined,
                          ),
                          const SizedBox(height: 16),

                          _buildCard(
                            child: UnitSelector(
                              selectedUnit: _selectedUnit,
                              onUnitSelected: _handleUnitSelected,
                              customUnit: _customUnit,
                              onCustomUnitChanged: _handleCustomUnitChanged,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Submit Button with improved design
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
                                onPressed: _handleSubmit,
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
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Add Product to Store',
                                      style: AppTextStyles.PRIMARY_BUTTON_TEXT
                                          .copyWith(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
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
