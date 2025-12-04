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
import 'package:bukidlink/models/Product.dart';

// Farmer Edit Product Page
class EditPage extends StatefulWidget {
  final Product product;
  const EditPage({super.key, required this.product});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final FarmService _farmService = FarmService();

  // Form controllers
  late TextEditingController _productNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _customUnitController;

  // Static SRP value for demo
  static const double _srp = 100.0;
  String? _priceAlert;

  // Form state
  bool _isLoading = false;
  String? _productImagePath;
  String? _selectedCategory;
  String? _selectedUnit;
  String? _customUnit;

  bool _hasChanges() {
    // Check if basic fields differ
    if (_productNameController.text != widget.product.name) return true;
    if (_descriptionController.text != (widget.product.description ?? ''))
      return true;
    if (_priceController.text != widget.product.price.toString()) return true;
    if (_stockController.text != widget.product.stockCount.toString())
      return true;

    // Check if image changed
    if (_productImagePath != widget.product.imagePath) return true;

    // Check if category changed
    if (_selectedCategory != widget.product.category) return true;

    // Check if unit changed
    // Current unit logic:
    // If _selectedUnit is 'Other', the unit is _customUnitController.text
    // Otherwise, it is _selectedUnit
    final String? currentUnit = _selectedUnit == 'Other'
        ? _customUnitController.text
        : _selectedUnit;

    // Original unit logic:
    // If widget.product.unit was effectively 'Other' (not in list), it might be different
    if (currentUnit != widget.product.unit) return true;

    return false;
  }

  Future<void> _handlePop(bool didPop) async {
    if (didPop) return;

    if (_hasChanges()) {
      final shouldPop = await _showDiscardChangesDialog();
      if (shouldPop == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool?> _showDiscardChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Discard Changes?', style: AppTextStyles.DIALOG_TITLE),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: AppTextStyles.BODY_TEXT,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.BODY_TEXT.copyWith(
                color: AppColors.TEXT_SECONDARY,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Discard',
              style: AppTextStyles.BODY_TEXT.copyWith(
                color: AppColors.ERROR_RED,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stockCount.toString(),
    );
    _productImagePath = widget.product.imagePath;
    _selectedCategory = widget.product.category;

    // Logic to handle custom units
    if (widget.product.unit != null &&
        !UnitSelector.units.contains(widget.product.unit) &&
        widget.product.unit != 'Other') {
      _selectedUnit = 'Other';
      _customUnit = widget.product.unit;
    } else {
      _selectedUnit = widget.product.unit;
      _customUnit = null;
    }

    _customUnitController = TextEditingController(text: _customUnit);

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
        .showImageSourceBottomSheet(context, 'Select Product Image Source');
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
        _customUnitController.clear();
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
    if (_productImagePath == null) {
      _showErrorDialog('Please add a product image');
      return;
    }
    if (_selectedCategory == null) {
      _showErrorDialog('Please select a category');
      return;
    }
    if (_selectedUnit == null) {
      _showErrorDialog('Please select how the product is sold');
      return;
    }

    // Update _customUnit from controller before validation
    if (_selectedUnit == 'Other') {
      _customUnit = _customUnitController.text;
    }

    if (_selectedUnit == 'Other' &&
        (_customUnit == null || _customUnit!.trim().isEmpty)) {
      _showErrorDialog('Please enter a custom unit');
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedProduct = widget.product.copyWith(
          name: _productNameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          stockCount: int.parse(_stockController.text),
          imagePath: _productImagePath,
          category: _selectedCategory,
          unit: _selectedUnit == 'Other' ? _customUnit : _selectedUnit,
        );

        await _farmService.updateProduct(updatedProduct);

        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Failed to update product: $e');
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
              'Product Updated',
              style: AppTextStyles.FORM_LABEL.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.SUCCESS_GREEN,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your product "${_productNameController.text}" has been successfully updated!',
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
                Navigator.of(context).pop(); // Go back to store
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
                'Close',
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handlePop(didPop),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _handlePop(false),
          ),
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
                child: const Icon(Icons.edit, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Product',
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
        body: Container(
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
                            customUnitController: _customUnitController,
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
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.ACCENT_LIME,
                                disabledBackgroundColor: AppColors.ACCENT_LIME
                                    .withOpacity(0.6),
                                foregroundColor: AppColors.DARK_TEXT,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 26,
                                      width: 26,
                                      child: CircularProgressIndicator(
                                        color: AppColors.DARK_TEXT,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.save_outlined,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Save Changes',
                                          style: AppTextStyles
                                              .PRIMARY_BUTTON_TEXT
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
      ),
    );
  }

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
