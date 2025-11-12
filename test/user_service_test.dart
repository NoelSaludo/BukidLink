import 'package:flutter_test/flutter_test.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/models/User.dart';

void main() {
  late UserService userService;

  setUp(() {
    userService = UserService();
  });

  group('generateUserId', () {
    test('generates non-empty user ID', () {
      final userId = userService.generateUserId();
      
      expect(userId, isNotEmpty);
    });

    test('generates unique user IDs on multiple calls', () {
      final userId1 = userService.generateUserId();
      final userId2 = userService.generateUserId();
      final userId3 = userService.generateUserId();
      
      expect(userId1, isNot(equals(userId2)));
      expect(userId1, isNot(equals(userId3)));
      expect(userId2, isNot(equals(userId3)));
    });

    test('generates valid UUID v4 format', () {
      final userId = userService.generateUserId();
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      
      expect(userId, matches(uuidPattern));
    });

    test('generates 100 unique IDs without collisions', () {
      final ids = <String>{};
      for (var i = 0; i < 100; i++) {
        ids.add(userService.generateUserId());
      }

      expect(ids.length, equals(100));
    });
  });

  group('User model', () {
    test('creates user from JSON correctly', () {
      final json = {
        'id': 'test-123',
        'firstName': 'Juan',
        'lastName': 'Dela Cruz',
        'email': 'juan@example.com',
        'contactNumber': '09123456789',
        'address': 'Manila, Philippines',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-01T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('test-123'));
      expect(user.firstName, equals('Juan'));
      expect(user.lastName, equals('Dela Cruz'));
      expect(user.email, equals('juan@example.com'));
      expect(user.contactNumber, equals('09123456789'));
      expect(user.address, equals('Manila, Philippines'));
      expect(user.fullName, equals('Juan Dela Cruz'));
    });

    test('converts user to JSON correctly', () {
      final user = User(
        id: 'test-123',
        firstName: 'Maria',
        lastName: 'Santos',
        email: 'maria@example.com',
        contactNumber: '09987654321',
        address: 'Quezon City',
        createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
      );

      final json = user.toJson();

      expect(json['id'], equals('test-123'));
      expect(json['firstName'], equals('Maria'));
      expect(json['lastName'], equals('Santos'));
      expect(json['email'], equals('maria@example.com'));
      expect(json['contactNumber'], equals('09987654321'));
      expect(json['address'], equals('Quezon City'));
    });

    test('creates user with nullable fields', () {
      final json = {
        'id': 'test-456',
        'firstName': 'Pedro',
        'lastName': 'Reyes',
        'email': 'pedro@example.com',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-01T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.contactNumber, isNull);
      expect(user.address, isNull);
    });

    test('copyWith creates new instance with updated fields', () {
      final user = User(
        id: 'test-789',
        firstName: 'Anna',
        lastName: 'Garcia',
        email: 'anna@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = user.copyWith(
        firstName: 'Ana',
        email: 'ana@example.com',
      );

      expect(updated.id, equals(user.id));
      expect(updated.firstName, equals('Ana'));
      expect(updated.lastName, equals('Garcia'));
      expect(updated.email, equals('ana@example.com'));
    });

    test('fullName concatenates first and last name', () {
      final user = User(
        id: 'test',
        firstName: 'Jose',
        lastName: 'Rizal',
        email: 'jose@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.fullName, equals('Jose Rizal'));
    });

    test('equality based on ID', () {
      final user1 = User(
        id: 'same-id',
        firstName: 'User',
        lastName: 'One',
        email: 'user1@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final user2 = User(
        id: 'same-id',
        firstName: 'User',
        lastName: 'Two',
        email: 'user2@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });
  });

  group('CreateUserRequest', () {
    test('converts to JSON with all fields', () {
      final request = CreateUserRequest(
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        email: 'juan@example.com',
        contactNumber: '09123456789',
        address: 'Manila, Philippines',
      );

      final json = request.toJson();

      expect(json['firstName'], equals('Juan'));
      expect(json['lastName'], equals('Dela Cruz'));
      expect(json['email'], equals('juan@example.com'));
      expect(json['contactNumber'], equals('09123456789'));
      expect(json['address'], equals('Manila, Philippines'));
    });

    test('converts to JSON without optional fields', () {
      final request = CreateUserRequest(
        firstName: 'Maria',
        lastName: 'Santos',
        email: 'maria@example.com',
      );

      final json = request.toJson();

      expect(json['firstName'], equals('Maria'));
      expect(json['lastName'], equals('Santos'));
      expect(json['email'], equals('maria@example.com'));
      expect(json.containsKey('contactNumber'), isFalse);
      expect(json.containsKey('address'), isFalse);
    });
  });

  group('UpdateUserRequest', () {
    test('converts to JSON with only specified fields', () {
      final request = UpdateUserRequest(
        firstName: 'Updated',
        email: 'updated@example.com',
      );

      final json = request.toJson();

      expect(json['firstName'], equals('Updated'));
      expect(json['email'], equals('updated@example.com'));
      expect(json.containsKey('lastName'), isFalse);
      expect(json.containsKey('contactNumber'), isFalse);
      expect(json.containsKey('address'), isFalse);
    });

    test('converts to empty JSON when no fields specified', () {
      final request = UpdateUserRequest();

      final json = request.toJson();

      expect(json.isEmpty, isTrue);
    });

    test('includes null values when explicitly set', () {
      final request = UpdateUserRequest(
        contactNumber: '09111111111',
      );

      final json = request.toJson();

      expect(json['contactNumber'], equals('09111111111'));
      expect(json.length, equals(1));
    });
  });

  group('bulk user ID generation', () {
    test('generates unique IDs for bulk creation', () {
      final requests = List.generate(
        50,
        (index) => CreateUserRequest(
          firstName: 'User$index',
          lastName: 'Test',
          email: 'user$index@example.com',
        ),
      );

      final ids = <String>[];
      for (var i = 0; i < requests.length; i++) {
        ids.add(userService.generateUserId());
      }

      expect(ids.toSet().length, equals(requests.length));
    });
  });
}
