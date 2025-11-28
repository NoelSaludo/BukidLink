import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/TradeModels.dart';
import '../../services/TradeService.dart';
import '../../services/UserService.dart';
import '../../Widgets/common/BouncingDotsLoader.dart';
import 'package:flutter/painting.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

// Small helper widget: shows a bouncing loader while an ImageProvider is resolving
class ImageWithLoader extends StatefulWidget {
  final ImageProvider image;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ImageWithLoader({
    Key? key,
    required this.image,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  _ImageWithLoaderState createState() => _ImageWithLoaderState();
}

class _ImageWithLoaderState extends State<ImageWithLoader> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  bool _isLoaded = false;

  void _listen() {
    _stream = widget.image.resolve(ImageConfiguration.empty);
    _listener = ImageStreamListener(
      (_, __) {
        if (mounted) setState(() => _isLoaded = true);
      },
      onError: (_, __) {
        if (mounted) setState(() => _isLoaded = true);
      },
    );
    _stream!.addListener(_listener!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stream == null) _listen();
  }

  @override
  void didUpdateWidget(covariant ImageWithLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      _isLoaded = false;
      _stream?.removeListener(_listener!);
      _listen();
    }
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null)
      _stream!.removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: widget.image,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
        ),
        if (!_isLoaded)
          Container(
            color: Colors.grey[100],
            child: Center(child: BouncingDotsLoader(size: 8.0)),
          ),
      ],
    );
  }
}

// --- Page: Detail View of Item to Trade For ---
class OfferTradePage extends StatelessWidget {
  final TradeListing listing;

  const OfferTradePage({required this.listing});

  @override
  Widget build(BuildContext context) {
    ImageProvider getImageProvider() {
      final img = listing.image.trim();
      final urlPattern = RegExp(r'^https?:\/\/');
      if (img.isEmpty)
        return AssetImage('assets/images/default_cover_photo.png');
      if (img.startsWith('assets/')) return AssetImage(img);
      if (urlPattern.hasMatch(img)) return NetworkImage(img);
      return FileImage(File(img));
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Offer a Trade',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card with image and basic info
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.06),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with overlay and offers badge
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ImageWithLoader(
                              image: getImageProvider(),
                              fit: BoxFit.cover,
                            ),
                            // bottom gradient + texts
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.45),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            listing.name,
                                            style: AppTextStyles
                                                .PRODUCT_INFO_TITLE
                                                .copyWith(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Qty: ${listing.quantity}',
                                            style: AppTextStyles.REVIEW_COUNT
                                                .copyWith(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // offers count badge
                                    if (listing.offersCount > 0)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.95),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.local_offer,
                                              size: 14,
                                              color: AppColors
                                                  .HEADER_GRADIENT_START,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${listing.offersCount} Offers',
                                              style: AppTextStyles.CAPTION
                                                  .copyWith(
                                                    color: AppColors.DARK_TEXT,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18),

              // Description
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.12),
                          AppColors.HEADER_GRADIENT_END.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Product Details',
                    style: AppTextStyles.FORM_LABEL.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF7F9F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  listing.description.isNotEmpty
                      ? listing.description
                      : 'No description provided.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Preferred trades
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.12),
                          AppColors.HEADER_GRADIENT_END.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Preferred Trades',
                    style: AppTextStyles.FORM_LABEL.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: listing.preferredTrades
                    .map(
                      (t) => Chip(
                        label: Text(
                          t,
                          style: AppTextStyles.BODY_MEDIUM.copyWith(
                            color: AppColors.DARK_TEXT,
                          ),
                        ),
                        backgroundColor: AppColors.ACCENT_LIME.withOpacity(
                          0.12,
                        ),
                      ),
                    )
                    .toList(),
              ),

              SizedBox(height: 90), // space for bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.ACCENT_LIME.withOpacity(0.36),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TradeRequestPage(listing: listing),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Offer a Trade',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ACCENT_LIME,
                foregroundColor: AppColors.DARK_TEXT,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Page: Form to Submit an Offer ---
class TradeRequestPage extends StatefulWidget {
  final TradeListing listing;

  TradeRequestPage({required this.listing});

  @override
  _TradeRequestPageState createState() => _TradeRequestPageState();
}

class _TradeRequestPageState extends State<TradeRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final TradeService _tradeService = TradeService();

  bool _isLoading = false;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) setState(() => _pickedImage = pickedFile);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_pickedImage != null)
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text(
                  'Remove photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _pickedImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOffer() async {
    if (_itemNameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Get Firebase Auth ID (reliable for ID)
      final firebaseUser = FirebaseAuth.instance.currentUser;
      String uid = firebaseUser?.uid ?? 'anon_user';

      // 2. Get Custom User Data (reliable for Username) from UserService
      // We use 'var' to avoid type conflict with FirebaseAuth.User vs Model.User
      var appUser = UserService().getCurrentUser();

      // Safety Fallback: If static user is null (e.g. app refresh), fetch it from Firestore
      if (appUser == null && firebaseUser != null) {
        appUser = await UserService().getUserById(firebaseUser.uid);
      }

      // Prioritize appUser.username, fallback to Anonymous
      String uName = appUser?.username ?? 'Anonymous';

      final offer = TradeOfferRequest(
        listingId: widget.listing.id,
        offeredByUid: uid,
        offeredByName: uName, // Correctly uses the username
        itemName: _itemNameController.text,
        itemQuantity: _quantityController.text,
        imagePath: _pickedImage?.path ?? '',
      );

      await _tradeService.submitOffer(offer);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Trade Offer Sent!')));
      Navigator.pop(context); // Close Form
      Navigator.pop(
        context,
      ); // Close Detail Page (Optional, depends on flow preference)
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
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Make an Offer',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
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
                  const Color(0xFFE8F5E9).withOpacity(0.2),
                ],
              ),
            ),
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
                    _buildSectionHeader('Offer Details', Icons.info_outline),
                    const SizedBox(height: 16),

                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trading for: ${widget.listing.name}',
                            style: AppTextStyles.BODY_MEDIUM.copyWith(
                              color: AppColors.TEXT_SECONDARY,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _itemNameController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter an item name'
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Your Item Name',
                              hintText: 'e.g. Apples',
                              filled: true,
                              fillColor: AppColors.BACKGROUND_WHITE,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.BORDER_GREY.withOpacity(0.2),
                                  width: 1.2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _quantityController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter quantity'
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Your Item Quantity',
                              hintText: 'e.g. 1 kg',
                              filled: true,
                              fillColor: AppColors.BACKGROUND_WHITE,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.BORDER_GREY.withOpacity(0.2),
                                  width: 1.2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader('Offer Image', Icons.image_outlined),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add an image of your offered item',
                            style: AppTextStyles.BODY_MEDIUM.copyWith(
                              color: AppColors.TEXT_SECONDARY,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _showImageOptions,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.BORDER_GREY.withOpacity(0.6),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withOpacity(
                                      0.02,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _pickedImage == null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 36,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Tap to upload photo',
                                            style: AppTextStyles.BODY_MEDIUM
                                                .copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: ImageWithLoader(
                                            image: FileImage(
                                              File(_pickedImage!.path),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: GestureDetector(
                                            onTap: () => setState(
                                              () => _pickedImage = null,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Submit Button
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
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    await _submitOffer();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ACCENT_LIME,
                            foregroundColor: AppColors.DARK_TEXT,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.send, size: 18),
                                    SizedBox(width: 10),
                                    Text(
                                      'Submit Offer',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
