class User {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? passwordHash;
  // DanielGalliego Password: SirJ0elB@cay
  final String? contactNumber;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.passwordHash,
    this.contactNumber,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle nested details object if it exists
    final details = json['details'] as Map<String, dynamic>?;

    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      firstName: details != null
          ? (details['first_name'] as String)
          : (json['firstName'] as String),
      lastName: details != null
          ? (details['last_name'] as String)
          : (json['lastName'] as String),
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String? ?? json['password'] as String?,
      contactNumber: details != null
          ? (details['contact_number'] as String?)
          : (json['contactNumber'] as String?),
      address: details != null
          ? (details['address'] as String?)
          : (json['address'] as String?),
      createdAt: details != null
          ? DateTime.parse(details['created_date'] as String)
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (passwordHash != null) 'passwordHash': passwordHash,
      'contactNumber': contactNumber,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? passwordHash,
    String? contactNumber,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Request model for creating a new user
class CreateUserRequest {
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? contactNumber;
  final String? address;

  CreateUserRequest({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.contactNumber,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      if (contactNumber != null) 'contactNumber': contactNumber,
      if (address != null) 'address': address,
    };
  }
}

/// Request model for updating a user
class UpdateUserRequest {
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? contactNumber;
  final String? address;

  UpdateUserRequest({
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.contactNumber,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (username != null) map['username'] = username;
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (email != null) map['email'] = email;
    if (password != null) map['password'] = password;
    if (contactNumber != null) map['contactNumber'] = contactNumber;
    if (address != null) map['address'] = address;
    return map;
  }
}
