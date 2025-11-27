import 'package:cloud_firestore/cloud_firestore.dart';

class Farm {
  final String id;
  final String name;
  final String address;
  final DocumentReference ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int followerCount;
  Farm({
    required this.id,
    required this.name,
    required this.address,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.followerCount = 0,
  });

  factory Farm.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Farm(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      ownerId: data['ownerId'] ?? '',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : DateTime.now(),
      followerCount: (data['followerCount'] is int)
          ? data['followerCount'] as int
          : (data['followerCount'] != null
                ? (data['followerCount'] as num).toInt()
                : 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'ownerId': ownerId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'followerCount': followerCount,
    };
  }
}
