import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Follow a farm: writes a follower doc under /farm/{farmId}/followers/{userId}
  // Returns the new follower count after the operation.
  Future<int> follow({required String farmId, required String userId}) async {
    final farmRef = _firestore.collection('farm').doc(farmId);
    final followerRef = farmRef.collection('followers').doc(userId);

    final int newCount = await _firestore.runTransaction<int>((tx) async {
      final followerSnap = await tx.get(followerRef);
      if (followerSnap.exists) {
        // already following; return current count
        final farmSnap = await tx.get(farmRef);
        final curr = (farmSnap.data()?['followerCount'] is int)
            ? farmSnap.data()!['followerCount'] as int
            : (farmSnap.data()?['followerCount'] != null
                  ? (farmSnap.data()!['followerCount'] as num).toInt()
                  : 0);
        return curr;
      }

      tx.set(followerRef, {
        'followerId': userId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      final farmSnap = await tx.get(farmRef);
      if (!farmSnap.exists) {
        // create farm doc with followerCount = 1 to be safe
        tx.set(farmRef, {
          'followerCount': 1,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return 1;
      } else {
        final curr = (farmSnap.data()?['followerCount'] is int)
            ? farmSnap.data()!['followerCount'] as int
            : (farmSnap.data()?['followerCount'] != null
                  ? (farmSnap.data()!['followerCount'] as num).toInt()
                  : 0);
        final newCountLocal = curr + 1;
        tx.update(farmRef, {
          'followerCount': newCountLocal,
          'updated_at': FieldValue.serverTimestamp(),
        });
        return newCountLocal;
      }
    });

    return newCount;
  }

  // Unfollow a farm: delete follower doc and decrement followerCount (not going below 0)
  // Returns the new follower count after the operation.
  Future<int> unfollow({required String farmId, required String userId}) async {
    final farmRef = _firestore.collection('farm').doc(farmId);
    final followerRef = farmRef.collection('followers').doc(userId);

    final int newCount = await _firestore.runTransaction<int>((tx) async {
      final followerSnap = await tx.get(followerRef);
      if (!followerSnap.exists) {
        // not following; return current count
        final farmSnap = await tx.get(farmRef);
        final curr = (farmSnap.data()?['followerCount'] is int)
            ? farmSnap.data()!['followerCount'] as int
            : (farmSnap.data()?['followerCount'] != null
                  ? (farmSnap.data()!['followerCount'] as num).toInt()
                  : 0);
        return curr;
      }

      tx.delete(followerRef);

      final farmSnap = await tx.get(farmRef);
      if (!farmSnap.exists) {
        return 0;
      }

      final current = (farmSnap.data()?['followerCount'] is int)
          ? farmSnap.data()!['followerCount'] as int
          : (farmSnap.data()?['followerCount'] != null
                ? (farmSnap.data()!['followerCount'] as num).toInt()
                : 0);

      final newCountLocal = (current - 1) < 0 ? 0 : current - 1;
      tx.update(farmRef, {
        'followerCount': newCountLocal,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return newCountLocal;
    });

    return newCount;
  }

  // Check one-time whether a user is following a farm
  Future<bool> isFollowing({
    required String farmId,
    required String userId,
  }) async {
    final doc = await _firestore
        .collection('farm')
        .doc(farmId)
        .collection('followers')
        .doc(userId)
        .get();
    return doc.exists;
  }

  // Stream that emits whether the current user is following the farm
  Stream<bool> isFollowingStream({
    required String farmId,
    required String userId,
  }) {
    return _firestore
        .collection('farm')
        .doc(farmId)
        .collection('followers')
        .doc(userId)
        .snapshots()
        .map((s) => s.exists);
  }

  // Stream list of follower IDs for a farm
  Stream<List<String>> followersStream({required String farmId}) {
    return _firestore
        .collection('farm')
        .doc(farmId)
        .collection('followers')
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((d) => (d.data()['followerId'] as String?) ?? d.id)
              .toList();
        });
  }

  // Stream follower count from farm doc
  Stream<int> followerCountStream({required String farmId}) {
    return _firestore.collection('farm').doc(farmId).snapshots().map((snap) {
      if (!snap.exists) return 0;
      final data = snap.data();
      if (data == null) return 0;
      final val = data['followerCount'];
      if (val is int) return val;
      if (val is num) return val.toInt();
      return 0;
    });
  }

  // Helper: get current follower count once
  Future<int> getFollowerCount({required String farmId}) async {
    final snap = await _firestore.collection('farm').doc(farmId).get();
    if (!snap.exists) return 0;
    final val = snap.data()?['followerCount'];
    if (val is int) return val;
    if (val is num) return val.toInt();
    return 0;
  }
}
