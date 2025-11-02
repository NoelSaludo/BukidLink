import 'package:bukidlink/models/User.dart';

class UserData {
  static final List<User> _allUsers = [
    // Fruits
    User(
      id: '1',
      username: 'Test User',
      password: 'fcf730b6d95236ecd3c9fc2d92d7b6b2bb061514961aec041d6c7a7192f592e4',
      firstName: 'Test',
      lastName: 'User',
      emailAddress: 'TestUser@gmail.com',
      address: 'street1,city1,region1',
      contactNumber: '09000000001',
      profilePic: 'farmer1.png',
      type: 'farmer',
      farm: 'Old Market, Batangas City',
    ),
  ];

  // Get all Consumers
  static List<User> getAllUsers() {
    return _allUsers;
  }

  // Get Consumer by ID
  static User? getUserById(String id) {
    try {
      return _allUsers.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static User getUserInfoById(String id) {
      return _allUsers.firstWhere((p) => p.id == id);
  }
  
  //temp function to insert new account for signup
  static void addConsumer(
    String username, 
    String hashedPassword, 
    String firstName, 
    String lastName, 
    String emailAddress, 
    String address, 
    String contactNumber,
    //String profilePic,
  ){
    User newConsumer = User(
      id: (_allUsers.length + 1).toString(), 
      username: username, 
      password: hashedPassword, 
      firstName: firstName, 
      lastName: lastName, 
      emailAddress: emailAddress, 
      address: address, 
      contactNumber: contactNumber,
      profilePic: 'default_profile',
      type: 'consumer',);
    _allUsers.add(newConsumer);
  }

  static void addFarmer(
    String username, 
    String hashedPassword, 
    String firstName, 
    String lastName, 
    String emailAddress, 
    String address, 
    String contactNumber,
    String farm,
    //String profilePic,
  ){
    User newFarmer = User(
      id: (_allUsers.length + 1).toString(), 
      username: username, 
      password: hashedPassword, 
      firstName: firstName, 
      lastName: lastName, 
      emailAddress: emailAddress, 
      address: address, 
      contactNumber: contactNumber,
      profilePic: 'default_profile',
      type: 'farmer',
      farm: farm);
    _allUsers.add(newFarmer);
  }
}
