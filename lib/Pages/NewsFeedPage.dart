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
import 'package:bukidlink/services/PostService.dart';

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    final fetchedPosts = await PostService().fetchPosts();
    setState(() {
      posts = fetchedPosts;
      isLoading = false;
    });
  }

  void refreshPosts() async {
    setState(() => isLoading = true);
    await loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.HEADER_GRADIENT_START,
        elevation: 0,
        title: Text(
          'News Feed',
          style: AppTextStyles.PRODUCT_INFO_TITLE,
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
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : posts.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return MakePost(
                            onPostCreated: refreshPosts,
                            text: "What's on your mind?",
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
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}