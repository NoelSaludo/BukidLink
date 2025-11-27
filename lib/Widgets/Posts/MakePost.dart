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

  String? _imageUrl;
  final ImagePickerService _imagePickerService = ImagePickerService();

  final user = UserService().getCurrentUser();

  Future<void> _pickImage() async {
    // Use ImagePickerService which uploads to Cloudinary and returns the secure URL
    final String? uploadedUrl = await _imagePickerService.pickFromGallery(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (uploadedUrl != null) {
      setState(() {
        _imageUrl = uploadedUrl;
      });
    }
  }

  Post _createNewPost() {
    final imageContent = _imageUrl ?? 'post1.png';

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
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Create Post",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Divider(),

                        // Post Text
                        TextFormField(
                          controller: _textController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "What's on your mind?",
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        const SizedBox(height: 12),

                        // Preview (shows uploaded Cloudinary image URL)
                        if (_imageUrl != null && _imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _imageUrl!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                          )
                        else
                          const Text(
                            'No image selected',
                            textAlign: TextAlign.center,
                          ),

                        const SizedBox(height: 15),

                        // Pick Image Button
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text("Pick Image"),
                          ),
                        ),

                        const SizedBox(height: 20),

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
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final post = _createNewPost();
                                  await PostService().createPost(post);
                                  widget.onPostCreated?.call();
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("Submit"),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = user?.profilePic;
    return GestureDetector(
      onTap: _showModal,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 240, 244, 230),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
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
                  ? NetworkImage(profileImage)
                  : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
            ),

            const SizedBox(width: 16),

            // --- Text ---
            Expanded(child: Text(widget.text, style: AppTextStyles.FORM_LABEL)),
          ],
        ),
      ),
    );
  }
}
