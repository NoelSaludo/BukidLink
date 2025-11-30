import 'package:bukidlink/models/Post.dart';
import 'package:bukidlink/models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final PostService _instance = PostService._internal();
  factory PostService() {
    return _instance;
  }
  PostService._internal();

  //Fetch Posts
  Future<List<Post>> fetchPosts() async {
    List<Post> posts = [];
    try {
      QuerySnapshot snapshot = await _firestore.collection('posts').get();

      for (var doc in snapshot.docs) {
        posts.add(Post.fromDocument(doc));
      }
    } catch (e) {
      print('Error fetching posts by farm: $e');
    }

    return posts;
  }

  // Fetch Posts associated with a specific User
  Future<List<Post>> fetchPostsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('posterID', isEqualTo: userId) // <-- compare to string
          .get();

      List<Post> posts = [];
      for (var doc in querySnapshot.docs) {
        posts.add(Post.fromDocument(doc));
      }
      return posts;
    } catch (e) {
      print("Error fetching user posts: $e");
      return [];
    }
  }

  // Add a new product to the farm (and global products collection)
  Future<void> createPost(Post post) async {
    try {
      final CollectionReference postsColl = _firestore.collection('posts');

      DocumentReference docRef;
      if (post.id.isNotEmpty) {
        docRef = postsColl.doc(post.id);
        await docRef.set(post.toJson());
      } else {
        docRef = postsColl.doc();
        final json = post.toJson();
        json['id'] = docRef.id;
        await docRef.set(json);
      }
    } catch (e) {
      debugPrint('Error adding post: $e');
      rethrow;
    }
  }

  // Soft delete (archive) a product
  Future<void> archivePost(String postId) async {
    if (postId.isEmpty) return;
    try {
      await _firestore.collection('posts').doc(postId).update({
        'isVisible': false,
      });
    } catch (e) {
      debugPrint('Error archiving post: $e');
      rethrow;
    }
  }

  // Restore an archived product
  Future<void> restoreProduct(String postId) async {
    if (postId.isEmpty) return;
    try {
      await _firestore.collection('posts').doc(postId).update({
        'isVisible': true,
      });
    } catch (e) {
      debugPrint('Error restoring post: $e');
      rethrow;
    }
  }

  Future<User> getUserByPost(String posterID) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(posterID)
        .get();
    if (!doc.exists) throw Exception('User not found');

    final data = doc.data()!;
    return User(
      id: doc.id,
      username: data['username'] ?? '',
      password: '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      // Support either 'email' or 'emailAddress' stored on user docs
      emailAddress: data['emailAddress'] ?? data['email'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      profilePic: data['profilePic'] ?? 'default_image.png',
      type: data['type'] ?? 'Consumer',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : DateTime.now(),
      farmId: data['farmId'] as DocumentReference?,
    );
  }

  // Update an existing product (only editable fields)
  // Future<void> updateProduct(Post post) async {
  //   if (post.id.isEmpty) return;
  //   try {
  //     // Map only the fields that are editable in EditPage
  //     // to avoid overwriting other fields like reviews, rating, etc.
  //     final Map<String, dynamic> updateData = {
  //       'name': product.name,
  //       'description': product.description,
  //       'price': product.price,
  //       'stock_count': product.stockCount,
  //       'imagePath': product.imagePath,
  //       'category': product.category,
  //       'unit': product.unit,
  //       // We can also update availability based on stock if needed,
  //       // but sticking to strictly edited fields for now.
  //     };

  //     await _firestore
  //         .collection('products')
  //         .doc(product.id)
  //         .update(updateData);
  //   } catch (e) {
  //     debugPrint('Error updating product: $e');
  //     rethrow;
  //   }
  // }

  // Fetch a Farm document given its DocumentReference
  // Future<Farm?> getFarmByReference(DocumentReference? farmRef) async {
  //   if (farmRef == null) {
  //     debugPrint('getFarmByReference called with null farmRef');
  //     return null;
  //   }
  //   try {
  //     final doc = await farmRef.get();
  //     if (!doc.exists) {
  //       debugPrint('No farm found for reference: ${farmRef.path}');
  //       return null;
  //     }
  //     return Farm.fromDocument(doc);
  //   } catch (e) {
  //     print('Error fetching farm by reference: $e');
  //     return null;
  //   }
  // }

  // // Convenience: fetch the farm for a given User model
  // Future<Farm?> getFarmForUser(User? user) async {
  //   if (user == null) return null;
  //   return await getFarmByReference(user.farmId);
  // }
}
