import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/farmer/CustomTextField.dart';
import 'package:bukidlink/services/cloudinary_service.dart';
import 'package:bukidlink/services/FarmService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:bukidlink/services/GeminiAIService.dart';

class SellPricePage extends StatefulWidget {
  final String productName;
  final String description;
  final String? productImagePath;
  final String category;
  final String unit;
  final int stockCount;

  const SellPricePage({
    super.key,
    required this.productName,
    required this.description,
    required this.productImagePath,
    required this.category,
    required this.unit,
    required this.stockCount,
  });

  @override
  State<SellPricePage> createState() => _SellPricePageState();
}

class _SellPricePageState extends State<SellPricePage> {
  final _formKey = GlobalKey<FormState>();
  final FarmService _farmService = FarmService();

  final TextEditingController _priceController = TextEditingController();

  bool _isLoading = false;
  bool _isSuggestLoading = true;
  String _suggestionMessage = '';
  bool? _isFarmProduce;
  String? _suggestedNumeric;

  @override
  void initState() {
    super.initState();
    _fetchAISuggestion();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchAISuggestion() async {
    setState(() {
      _isSuggestLoading = true;
    });
    try {
      final res = await GeminiAIService().suggestPrice(
        name: widget.productName,
        unit: widget.unit,
      );
      setState(() {
        _suggestionMessage = res.message;
        _isFarmProduce = res.isFarmProduce;

        // Try to extract numeric amount from message
        final pesoRegex = RegExp(r'₱\s*([0-9,]+(?:\.[0-9]{1,2})?)');
        final numRegex = RegExp(r'([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?)');
        final pesoMatch = pesoRegex.firstMatch(res.message);
        if (pesoMatch != null && pesoMatch.groupCount >= 1) {
          _suggestedNumeric = pesoMatch.group(1)!.replaceAll(',', '');
        } else {
          final numMatch = numRegex.firstMatch(res.message);
          if (numMatch != null && numMatch.groupCount >= 1) {
            _suggestedNumeric = numMatch.group(1)!.replaceAll(',', '');
          }
        }
      });
    } catch (e) {
      setState(() {
        _suggestionMessage = 'AI suggestion failed';
        _isFarmProduce = false;
      });
    } finally {
      setState(() {
        _isSuggestLoading = false;
      });
    }
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Please enter price';
    final price = double.tryParse(value);
    if (price == null) return 'Please enter a valid number';
    if (price <= 0) return 'Price must be greater than 0';
    return null;
  }

  Future<void> _handleSubmit() async {
    if (_isFarmProduce == false) return; // blocked

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = UserService().getCurrentUser();
      if (user == null) throw Exception('No user logged in');

      final Farm? farm = await _farmService.getFarmForUser(user);
      if (farm == null) throw Exception('User has no associated farm');

      final double price = double.parse(_priceController.text);
      final int stockCount = widget.stockCount;
      final String availability = stockCount > 0 ? 'In Stock' : 'Out of Stock';

      final String unit = widget.unit;

      String imageUrl = '';
      if (widget.productImagePath != null &&
          widget.productImagePath!.isNotEmpty) {
        if (widget.productImagePath!.startsWith('http://') ||
            widget.productImagePath!.startsWith('https://')) {
          imageUrl = widget.productImagePath!;
        } else {
          final uploaded = await CloudinaryService().uploadFile(
            File(widget.productImagePath!),
          );
          if (uploaded != null && uploaded.isNotEmpty) imageUrl = uploaded;
        }
      }

      final product = Product(
        id: '',
        name: widget.productName,
        farmerId: user.id,
        farmName: farm.name,
        farmId: farm.id,
        imagePath: imageUrl,
        category: widget.category,
        price: price,
        description: widget.description,
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 12),
            const Text('Product Added'),
            const SizedBox(height: 8),
            Text('Your product "${"${widget.productName}"}" has been added.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Back to Store'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitDisabled = (_isFarmProduce == false);

    return Scaffold(
      appBar: AppBar(title: const Text('Set Price')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Pricing',
                    Icons.monetization_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'Price',
                          hint: '0.00',
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validatePrice,
                          prefix: Text(
                            '₱',
                            style: AppTextStyles.PESO_SYMBOL.copyWith(
                              fontSize: 18,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isSuggestLoading)
                          Row(
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(width: 12),
                              Text('Fetching AI suggestion...'),
                            ],
                          )
                        else ...[
                          Text(
                            _suggestionMessage,
                            style: AppTextStyles.BODY_MEDIUM.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_isFarmProduce == true &&
                              _suggestedNumeric != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  _priceController.text = _suggestedNumeric!;
                                },
                                child: const Text('Use suggestion'),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitDisabled ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: submitDisabled
                            ? Colors.grey
                            : AppColors.ACCENT_LIME,
                      ),
                      child: const Text('Add Product to Store'),
                    ),
                  ),
                ],
              ),
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
