import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/data/PostData.dart';
import 'package:bukidlink/Widgets/Posts/PostTile.dart';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';
import 'package:bukidlink/Widgets/Posts/MakePost.dart';

class NewsfeedPage extends StatefulWidget {
  @override
  _NewsfeedPageState createState() => _NewsfeedPageState();
}

class _NewsfeedPageState extends State<NewsfeedPage> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    posts = PostData.getAllPosts();
  }

  void refreshPosts() {
    setState(() {
      posts = PostData.getAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const FarmerAppBar(),
          Expanded(
            child: posts.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: posts.length + 1, // +1 for MakePost container
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // insert MakePost at the top
                      return MakePost(
                        onPostCreated: refreshPosts, // pass callback
                        text: 'What\'s on your mind?'
                      );
                    }
                    final post = posts[index - 1];
                    return PostTile(post: post);
                  },
                )
              : Center(
                  child: Text(
                    'No Posts yet',
                    style: AppTextStyles.sectionTitle,
                  ),
                ),
          ),
        ],
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 2),
    );
  }
}
