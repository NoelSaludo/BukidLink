import 'package:uuid/uuid.dart';
import '../models/User.dart';
import 'ApiClient.dart';

/// Service for managing user-related operations
/// Handles CRUD operations and user_id generation
class UserService {
  final ApiClient _apiClient = ApiClient();
  final Uuid _uuid = const Uuid();

  // API endpoints
  static const String _usersEndpoint = '/users';

  /// Generate a unique user ID
  /// Uses UUID v4 for guaranteed uniqueness
  String generateUserId() {
    return _uuid.v4();
  }

  /// Create a new user
  /// Generates a unique user_id and sends to the server
  Future<User> createUser(CreateUserRequest request) async {
    try {
      // Generate unique user ID
      final userId = generateUserId();
      final now = DateTime.now();

      // Prepare request data with generated ID
      final requestData = {
        'id': userId,
        ...request.toJson(),
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final response = await _apiClient.post(
        _usersEndpoint,
        data: requestData,
      );

      return User.fromJson(response.data);
    } on ApiException catch (e) {
      throw Exception('Failed to create user: ${e.message}');
    }
  }

  /// Get a user by ID
  Future<User> getUserById(String userId) async {
    try {
      final response = await _apiClient.get('$_usersEndpoint/$userId');
      return User.fromJson(response.data);
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw Exception('User not found');
      }
      throw Exception('Failed to get user: ${e.message}');
    }
  }

  /// Get all users
  /// Supports optional pagination parameters
  Future<List<User>> getAllUsers({
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final response = await _apiClient.get(
        _usersEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final List<dynamic> usersJson = response.data is List
          ? response.data
          : (response.data['users'] ?? response.data['data'] ?? []);

      return usersJson.map((json) => User.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw Exception('Failed to get users: ${e.message}');
    }
  }

  /// Update an existing user
  Future<User> updateUser(String userId, UpdateUserRequest request) async {
    try {
      final requestData = {
        ...request.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final response = await _apiClient.put(
        '$_usersEndpoint/$userId',
        data: requestData,
      );

      return User.fromJson(response.data);
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw Exception('User not found');
      }
      throw Exception('Failed to update user: ${e.message}');
    }
  }

  /// Partially update a user (PATCH)
  Future<User> patchUser(String userId, UpdateUserRequest request) async {
    try {
      final requestData = {
        ...request.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final response = await _apiClient.patch(
        '$_usersEndpoint/$userId',
        data: requestData,
      );

      return User.fromJson(response.data);
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw Exception('User not found');
      }
      throw Exception('Failed to update user: ${e.message}');
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _apiClient.delete('$_usersEndpoint/$userId');
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw Exception('User not found');
      }
      throw Exception('Failed to delete user: ${e.message}');
    }
  }

  /// Search users by name or email
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _apiClient.get(
        '$_usersEndpoint/search',
        queryParameters: {'q': query},
      );

      final List<dynamic> usersJson = response.data is List
          ? response.data
          : (response.data['users'] ?? response.data['data'] ?? []);

      return usersJson.map((json) => User.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw Exception('Failed to search users: ${e.message}');
    }
  }

  /// Check if email already exists
  Future<bool> emailExists(String email) async {
    try {
      final response = await _apiClient.get(
        '$_usersEndpoint/check-email',
        queryParameters: {'email': email},
      );

      return response.data['exists'] == true;
    } on ApiException catch (e) {
      throw Exception('Failed to check email: ${e.message}');
    }
  }

  /// Bulk create users
  /// Generates unique IDs for all users
  Future<List<User>> createUsers(List<CreateUserRequest> requests) async {
    try {
      final now = DateTime.now();
      final usersData = requests.map((request) {
        return {
          'id': generateUserId(),
          ...request.toJson(),
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };
      }).toList();

      final response = await _apiClient.post(
        '$_usersEndpoint/bulk',
        data: {'users': usersData},
      );

      final List<dynamic> usersJson = response.data is List
          ? response.data
          : (response.data['users'] ?? response.data['data'] ?? []);

      return usersJson.map((json) => User.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw Exception('Failed to create users: ${e.message}');
    }
  }

  /// Get users count
  Future<int> getUsersCount() async {
    try {
      final response = await _apiClient.get('$_usersEndpoint/count');
      return response.data['count'] ?? 0;
    } on ApiException catch (e) {
      throw Exception('Failed to get users count: ${e.message}');
    }
  }
}

