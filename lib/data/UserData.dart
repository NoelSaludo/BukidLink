import 'package:bukidlink/models/User.dart';

class UserData {
  static final List<User> _allUsers = [
    // Users
    User(
      id: '1',
      username: 'Tindahan ni Lourdes',
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
    User(
      id: '2',
      username: 'Fernandez Domingo',
      password: 'fcf730b6d95236ecd3c9fc2d92d7b6b2bb061514961aec041d6c7a7192f592e4',
      firstName: 'Test',
      lastName: 'User',
      emailAddress: 'TestUser@gmail.com',
      address: 'street1,city1,region1',
      contactNumber: '09000000001',
      profilePic: 'farmer2.png',
      type: 'farmer',
      farm: 'New Market, Batangas City',
    ),
    User(
      id: '3',
      username: 'Farmjuseyo',
      password: 'fcf730b6d95236ecd3c9fc2d92d7b6b2bb061514961aec041d6c7a7192f592e4',
      firstName: 'Test',
      lastName: 'User',
      emailAddress: 'TestUser@gmail.com',
      address: 'street1,city1,region1',
      contactNumber: '09000000001',
      profilePic: 'farmer3.png',
      type: 'farmer',
      farm: 'Old Market, Batangas City',
    ),

    // CUSTOMERS
    User(
      id: '4',
      username: 'JuanDelaCruz',
      password: 'fcf730b6d95236ecd3c9fc2d92d7b6b2bb061514961aec041d6c7a7192f592e4',
      firstName: 'Juan',
      lastName: 'Dela Cruz',
      emailAddress: 'juan@example.com',
      address: 'Barangay 1, Batangas City',
      contactNumber: '09123456789',
      profilePic: 'customer1.png',
      type: 'consumer',
    ),
    User(
      id: '5',
      username: 'MariaSantos',
      password: 'fcf730b6d95236ecd3c9fc2d92d7b6b2bb061514961aec041d6c7a7192f592e4',
      firstName: 'Maria',
      lastName: 'Santos',
      emailAddress: 'maria@example.com',
      address: 'Barangay 2, Batangas City',
      contactNumber: '09123456780',
      profilePic: 'customer2.png',
      type: 'consumer',
    ),
    User(
      id: '6',
      username: 'PedroReyes',
      password: 'fcf730b6d95236ecd3c9fc2d92d7b6b2bb061514961aec041d6c7a7192f592e4',
      firstName: 'Pedro',
      lastName: 'Reyes',
      emailAddress: 'pedro@example.com',
      address: 'Barangay 3, Batangas City',
      contactNumber: '09123456781',
      profilePic: 'customer3.png',
      type: 'consumer',
    ),
    User(
      id: '7',
      username: 'AnaLopez',
      password: 'fcf730b6d95236ecd3c9fc2d92d7b6b2bb061514961aec041d6c7a7192f592e4',
      firstName: 'Ana',
      lastName: 'Lopez',
      emailAddress: 'ana@example.com',
      address: 'Barangay 4, Batangas City',
      contactNumber: '09123456782',
      profilePic: 'customer4.png',
      type: 'consumer',
    ),
  ];

  // Get all Users
  static List<User> getAllUsers() {
    return _allUsers;
  }

  // Get all Customers
  static List<User> getAllCustomers() {
    return _allUsers.where((u) => u.type == 'consumer').toList();
  }

  // Get User by ID
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
  
  //temp function to insert new consumer for signup
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
//temp function to insert new farmer for signup
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
