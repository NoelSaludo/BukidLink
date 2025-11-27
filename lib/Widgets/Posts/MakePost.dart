import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/services/PostService.dart';
import 'package:bukidlink/services/UserService.dart';

class MakePost extends StatefulWidget {
  final String text; // Text shown in the tappable container
  final VoidCallback? onPostCreated;

  const MakePost({Key? key, this.text = "This is the single scrollable container", this.onPostCreated}) : super(key: key);

  @override
  _MakePostState createState() => _MakePostState();
}

class _MakePostState extends State<MakePost> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _imageUrlController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final user = UserService().getCurrentUser();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrlController.clear(); // Clear URL if a file is picked
      });
    }
  }

  Post _createNewPost() {
    String imageContent;

    if (_imageUrlController.text.isNotEmpty) {
      imageContent = _imageUrlController.text;
    } else if (_imageFile != null) {
      imageContent = 'post1.png'; // Replace with actual upload path if needed
    } else {
      imageContent = 'post1.png';
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
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

                        // Image URL input
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            hintText: "Enter image URL (optional)",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              modalSetState(() {
                                _imageFile = null; // Clear picked file
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Preview
                        if (_imageFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (_imageUrlController.text.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _imageUrlController.text,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                            ),
                          )
                        else
                          const Text('No image selected', textAlign: TextAlign.center),

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
                        )
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
            : const AssetImage('assets/images/default_profile.png') as ImageProvider,
            ),

          const SizedBox(width: 16),

          // --- Text ---
          Expanded(
            child: Text(
              widget.text,
              style: AppTextStyles.FORM_LABEL,
            ),
          ),
        ],
      ),
    ),
  );
}
}