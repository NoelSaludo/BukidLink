class User{
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
  final String? farmName;
  final String? farmAddress;
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
    this.farmName,
    this.farmAddress
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
      'farmName': farmName,
      'farmAddress': farmAddress,
    };
  }
}