import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bukidlink/services/ImagePickerService.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/services/PostService.dart';
import 'package:bukidlink/services/UserService.dart';

class MakePost extends StatefulWidget {
  final String text; // Text shown in the tappable container
  final VoidCallback? onPostCreated;

  const MakePost({
    Key? key,
    this.text = "This is the single scrollable container",
    this.onPostCreated,
  }) : super(key: key);

  @override
  _MakePostState createState() => _MakePostState();
}

class _MakePostState extends State<MakePost> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _imageUrlController = TextEditingController();

  File? _imageFile;

  final user = UserService().getCurrentUser();

  Future<void> _pickImage() async {
    // Use ImagePickerService which uploads the picked image to Cloudinary
    // and returns the secure URL. This ensures image URLs are stored
    // in the Post model instead of raw local file paths.
    try {
      final String? uploadedUrl = await ImagePickerService().pickFromGallery(
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() {
          _imageFile = null; // we use the uploaded URL instead of local file
          _imageUrlController.text = uploadedUrl;
        });
      }
    } catch (e) {
      // If upload/pick failed, keep UI responsive and optionally show a message
      debugPrint('Image pick/upload failed: $e');
    }
  }

  Post _createNewPost() {
    String imageContent;

    if (_imageUrlController.text.isNotEmpty) {
      imageContent = _imageUrlController.text;
    } else if (_imageFile != null) {
      imageContent = ''; // Replace with actual upload path if needed
    } else {
      imageContent = '';
    }

    return Post(
      id: '',
      textContent: _textController.text,
      imageContent: imageContent,
      createdAt: DateTime.now(),
      posterID: UserService().getSafeUserId(),
    );
  }

  void _showModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Header
                        // resolve profile image for modal
                        Builder(
                          builder: (context) {
                            final modalProfile = user?.profilePic;
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      (modalProfile != null &&
                                          modalProfile.isNotEmpty)
                                      ? (modalProfile.toLowerCase().startsWith(
                                              'http',
                                            )
                                            ? NetworkImage(modalProfile)
                                            : AssetImage(
                                                    'assets' + modalProfile,
                                                  )
                                                  as ImageProvider)
                                      : const AssetImage(
                                          'assets/images/default_profile.png',
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Create Post",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // Post Text
                        TextFormField(
                          controller: _textController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: "What's on your mind?",
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (_) => modalSetState(() {}),
                          validator: (value) {
                            if ((value == null || value.trim().isEmpty) &&
                                _imageFile == null &&
                                _imageUrlController.text.isEmpty) {
                              return 'Please enter text or attach an image';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        // Action toolbar
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Pick from gallery',
                              onPressed: () async {
                                await _pickImage();
                                modalSetState(() {});
                              },
                              icon: const Icon(
                                Icons.photo_library,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Paste image URL',
                              onPressed: () {
                                modalSetState(() {
                                  _imageFile = null;
                                });
                                // Focus the URL field for quick paste
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                              },
                              icon: const Icon(Icons.link, color: Colors.blue),
                            ),
                            if (_imageFile != null ||
                                _imageUrlController.text.isNotEmpty)
                              IconButton(
                                tooltip: 'Remove image',
                                onPressed: () {
                                  modalSetState(() {
                                    _imageFile = null;
                                    _imageUrlController.clear();
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                              ),
                            const Spacer(),
                            // character count
                            Text(
                              '${_textController.text.trim().length}/1000',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Image URL input (compact)
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            hintText: "Image URL (optional)",
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: _imageUrlController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    onPressed: () => modalSetState(() {}),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            modalSetState(() {
                              if (value.isNotEmpty)
                                _imageFile = null; // Clear picked file
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // Preview
                        if (_imageFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (_imageUrlController.text.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _imageUrlController.text,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                          )
                        else
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'No image selected',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Submit & Cancel Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed:
                                  (_textController.text.trim().isNotEmpty ||
                                      _imageFile != null ||
                                      _imageUrlController.text.isNotEmpty)
                                  ? () async {
                                      if (_formKey.currentState!.validate()) {
                                        final post = _createNewPost();
                                        await PostService().createPost(post);
                                        widget.onPostCreated?.call();
                                        Navigator.pop(context);
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text("Post"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = user?.profilePic;

    return GestureDetector(
      onTap: _showModal,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 240, 244, 230),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // more visible shadow
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Profile Image ---
            CircleAvatar(
              radius: 22,
              backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                  ? (profileImage.toLowerCase().startsWith('http')
                        ? NetworkImage(profileImage)
                        : AssetImage('assets' + profileImage) as ImageProvider)
                  : const AssetImage('assets/images/default_profile.png'),
            ),

            const SizedBox(width: 16),

            // --- Text ---
            Expanded(
              child: Text(
                widget.text,
                style: AppTextStyles.FORM_LABEL.copyWith(
                  fontSize: 14, // slightly smaller than username
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
