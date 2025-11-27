import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String emailAddress;
  final String address;
  final String contactNumber;
  final String profilePic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? type;
  final DocumentReference? farmId;
  User({
    required this.id,
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.address,
    required this.contactNumber,
    required this.profilePic,
    required this.createdAt,
    required this.updatedAt,
    this.type,
    this.farmId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'emailAddress': emailAddress,
      'address': address,
      'contactNumber': contactNumber,
      'profilePic': profilePic,
      'type': type,
      'farmId': farmId,
    };
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return User(
      id: doc.id,
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      emailAddress: data['emailAddress'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      profilePic: data['profilePic'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      type: data['type'],
      farmId: data['farmId'],
    );
  }
}
