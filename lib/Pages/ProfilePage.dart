import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/Profile/ProfileInfo.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/Widgets/Posts/PostTile.dart';
import 'package:bukidlink/services/PostService.dart';

<<<<<<< HEAD
class ProfilePage extends StatelessWidget {
  final String profileID;
  const ProfilePage({super.key, required this.profileID});
=======
class ProfilePage extends StatefulWidget {
  final String profileID;

  const ProfilePage({
    super.key,
    required this.profileID,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserPosts();
  }

  Future<void> loadUserPosts() async {
    final fetchedPosts =
        await PostService().fetchPostsByUser(widget.profileID);

    setState(() {
      posts = fetchedPosts;
      isLoading = false;
    });
  }
>>>>>>> origin/PostFirebase

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: CustomScrollView(
        slivers: [
<<<<<<< HEAD
          // Sliver for user info section
          SliverToBoxAdapter(child: ProfileInfo(profileID: profileID)),
=======
          // Profile header
          SliverToBoxAdapter(
            child: ProfileInfo(profileID: widget.profileID),
          ),
>>>>>>> origin/PostFirebase

          // Title section
          const SliverToBoxAdapter(
            child: Column(
              children: [
                Divider(thickness: 1),
<<<<<<< HEAD
                Text('Posts History', style: AppTextStyles.PRODUCT_NAME_HEADER),
              ],
            ),
          ),
          // Sliver list for user posts
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = posts[index];
              return PostTile(post: post);
            }, childCount: posts.length),
          ),
=======
                Text(
                  'Posts History',
                  style: AppTextStyles.PRODUCT_NAME_HEADER,
                ),
              ],
            ),
          ),

          // Loading indicator
          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (posts.isEmpty)
            // No posts found
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No posts yet',
                    style: AppTextStyles.sectionTitle,
                  ),
                ),
              ),
            )
          else
            // List of posts
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  return PostTile(post: post);
                },
                childCount: posts.length,
              ),
            ),
>>>>>>> origin/PostFirebase
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
