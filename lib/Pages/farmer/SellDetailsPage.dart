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
import 'SellPricePage.dart';

class SellDetailsPage extends StatefulWidget {
  const SellDetailsPage({super.key});

  @override
  State<SellDetailsPage> createState() => _SellDetailsPageState();
}

class _SellDetailsPageState extends State<SellDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePickerService _imagePickerService = ImagePickerService();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String? _productImagePath;
  String? _selectedCategory;
  String? _selectedUnit;
  String? _customUnit;

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
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
      }
    });
  }

  void _handleCustomUnitChanged(String value) {
    setState(() {
      _customUnit = value;
    });
  }

  String? _validateProductName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter product name';
    if (value.length < 2) return 'Product name must be at least 2 characters';
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty)
      return 'Please enter product description';
    if (value.length < 10) return 'Description must be at least 10 characters';
    return null;
  }

  void _onNext() {
    if (_selectedCategory == null) {
      _showErrorDialog('Please select a category');
      return;
    }

    if (_selectedUnit == null) {
      _showErrorDialog('Please select how the product is sold');
      return;
    }

    if (_selectedUnit == 'Other' &&
        (_customUnit == null || _customUnit!.trim().isEmpty)) {
      _showErrorDialog('Please enter a custom unit');
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final unit = _selectedUnit == 'Other' ? _customUnit! : _selectedUnit!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellPricePage(
            productName: _productNameController.text.trim(),
            description: _descriptionController.text.trim(),
            productImagePath: _productImagePath,
            category: _selectedCategory!,
            unit: unit,
            stockCount: int.tryParse(_stockController.text) ?? 0,
          ),
        ),
      );
    }
  }

  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) return 'Please enter stock';
    final stock = int.tryParse(value);
    if (stock == null) return 'Please enter a valid number';
    if (stock < 0) return 'Stock cannot be negative';
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
              child: const Icon(
                Icons.storefront,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Basic Information', Icons.info_outline),
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
              _buildSectionHeader('Product Image', Icons.image_outlined),
              const SizedBox(height: 12),
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
              _buildSectionHeader('Category', Icons.category_outlined),
              const SizedBox(height: 12),
              _buildCard(
                child: CategorySelector(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _handleCategorySelected,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Stock', Icons.inventory_2_outlined),
              const SizedBox(height: 12),
              _buildCard(
                child: CustomTextField(
                  label: 'Stock',
                  hint: '0',
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  validator: _validateStock,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                'Unit of Sale',
                Icons.shopping_basket_outlined,
              ),
              const SizedBox(height: 12),
              _buildCard(
                child: UnitSelector(
                  selectedUnit: _selectedUnit,
                  onUnitSelected: _handleUnitSelected,
                  customUnit: _customUnit,
                  onCustomUnitChanged: _handleCustomUnitChanged,
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
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ACCENT_LIME,
                      foregroundColor: AppColors.DARK_TEXT,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Next: Set Price',
                      style: TextStyle(
                        fontFamily: AppTextStyles.FONT_FAMILY,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
      ),
      child: child,
    );
  }
}
