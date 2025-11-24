import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';
import 'package:bukidlink/data/PostData.dart';

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
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

void _createNewPost(BuildContext context){
  insertNewPost(
    _textController.text,
    'post3.png',
    '1',
  );
}

  void _showModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full height + smooth keyboard push
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
    builder: (context, modalSetState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Avoid keyboard overlap
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

                    // Title
                    const Center(
                      child: Text(
                        "Create Post",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Divider(),

                    // TEXT FIELD
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

                    // IMAGE SECTION (Centered)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        // IMAGE PREVIEW OR TEXT
                        _imageFile == null
                        ? const Center(
                        child: Text(
                          'No image selected',
                          textAlign: TextAlign.center,
                        ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // PICK IMAGE BUTTON (Centered)
                        Center(
                          child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text("Pick Image"),
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 20),

                    // BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _createNewPost(context);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Text(
          widget.text,
          style: AppTextStyles.FORM_LABEL
        ),
      ),
    );
  }
}

Future<void> insertNewPost(
    String textContent,
    String imageContent,
    String posterID) async{
      // final db = await;//access database
      // if(accountType.value == 'Consumer'){
      //   await db.insert(
      //     'Consumer',
      //     {
      //       'username': username,
      //       'password': hashedPassword,
      //       'firstName': firstName,
      //       'lastName': lastName,
      //       'emailAddress': emailAddress,
      //       'address': address,
      //       'contactNumber': contactNumber
      //     }
      //   );
      // }
      
      //adds consumer object to consumerData
      PostData.addPost(
        textContent,
        imageContent,
        posterID
        );
  }