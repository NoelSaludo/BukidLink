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

class NewsfeedPage extends StatefulWidget {
  @override
  _NewsfeedPageState createState() => _NewsfeedPageState();
}

class _NewsfeedPageState extends State<NewsfeedPage> {
  List<Post> posts = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      backgroundColor: AppColors.APP_BACKGROUND,
      body: SafeArea(
        child: Column(
          children: [
            const FarmerAppBar(),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryGreen,
                      onRefresh: () async => refreshPosts(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: posts.isEmpty ? 2 : posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return MakePost(
                              onPostCreated: refreshPosts,
                              text: "What's on your mind?",
                            );
                          }

                          if (posts.isEmpty && index == 1) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 12),
                                  Icon(
                                    Icons.feed,
                                    size: 72,
                                    color: AppColors.HEADER_GRADIENT_START,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No posts yet',
                                    style: AppTextStyles.EMPTY_STATE_TITLE,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Be the first to share an update with your community.',
                                    style: AppTextStyles.EMPTY_STATE_SUBTITLE,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      _scrollController.animateTo(
                                        0,
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Tap "What\'s on your mind?" to create a post')),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      child: Text('Create Post'),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            );
                          }

                          final post = posts[index - 1];
                          return PostTile(post: post);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 2),
    );
  }
}
