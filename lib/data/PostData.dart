import 'package:bukidlink/models/Post.dart';
import 'package:flutter/material.dart';

class PostData {
  static final List<Post> _allPosts = [
    // Posts
    Post(
      id: '1',
      textContent: 'Bili na kayo mga suki!;khbdfocgbuierbogwbgouwvbfoiuwboifubvwivfuwivbfwiu',
      imageContent: 'post1.png',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      posterID: '1',
    ),
    Post(
      id: '2',
      textContent:'Fresh fruits available at our store!',
      imageContent: 'post2.png',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      posterID: '2',
    ),
  ];

  // Get all Posts
  static List<Post> getAllPosts() {
    return _allPosts;
  }
  
  static void addPost(
    String textContent,
    String imageContent,
    String posterID
  ){
    Post newPost = Post(
      id: (_allPosts.length + 1).toString(), 
      textContent: textContent,
      imageContent: imageContent,
      posterID: posterID);
    _allPosts.add(newPost);
  }
}
