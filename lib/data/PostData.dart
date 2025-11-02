import 'package:bukidlink/models/Post.dart';
import 'package:flutter/material.dart';

class PostData {
  static final List<Post> _allPosts = [
    // Fruits
    Post(
      id: '1',
      textContent: 'Bili na kayo mga suki!',
      imageContent: 'post1.png',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      posterID: '1',
    ),
    Post(
      id: '2',
      textContent:'Check out this sample post, it uses a sample image that is not quite on theme yet but this is just to see if it works',
      imageContent: 'post2.png',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      posterID: '1',
    ),
  ];

  // Get all Consumers
  static List<Post> getAllPosts() {
    return _allPosts;
  }
}
