import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bukidlink/models/Message.dart';
import 'package:bukidlink/services/UserService.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  String conversationIdFor(String uidA, String uidB) {
    final List<String> parts = [uidA, uidB]..sort();
    return '${parts[0]}_${parts[1]}';
  }

  Future<String> createConversation(
    String uidA,
    String uidB, {
    String? initialText,
  }) async {
    final String convoId = conversationIdFor(uidA, uidB);
    final DocumentReference convoRef = _firestore
        .collection('conversations')
        .doc(convoId);

    final doc = await convoRef.get();
    if (!doc.exists) {
      await convoRef.set({
        'id': convoId,
        'participants': [uidA, uidB],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (initialText != null && initialText.isNotEmpty) {
        final messagesRef = convoRef.collection('messages');
        await messagesRef.add({
          'senderId': uidA,
          'sender': UserService.currentUser?.username ?? uidA,
          'text': initialText,
          'time': FieldValue.serverTimestamp(),
          'type': 'text',
        });
      }
    }

    return convoId;
  }

  Future<DocumentReference> sendMessage(
    String conversationId,
    String senderId,
    String text, {
    String type = 'text',
    Map<String, dynamic>? meta,
  }) async {
    final DocumentReference convoRef = _firestore
        .collection('conversations')
        .doc(conversationId);
    final CollectionReference messagesRef = convoRef.collection('messages');

    final messageData = <String, dynamic>{
      'senderId': senderId,
      'sender': UserService.currentUser?.username ?? senderId,
      'text': text,
      'time': FieldValue.serverTimestamp(),
      'type': type,
    };
    if (meta != null) messageData['meta'] = meta;

    final WriteBatch batch = _firestore.batch();
    final DocumentReference newMsgRef = messagesRef.doc();
    batch.set(newMsgRef, messageData);
    batch.update(convoRef, {'updatedAt': FieldValue.serverTimestamp()});

    await batch.commit();
    return newMsgRef;
  }

  Stream<List<Message>> streamMessages(
    String conversationId, {
    int limit = 50,
  }) {
    final String? currentUid = UserService.currentUser?.id;
    final Query ref = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('time', descending: false)
        .limit(limit);

    return ref.snapshots().map((snap) {
      return snap.docs
          .map(
            (d) => Message.fromJson(
              d.data() as Map<String, dynamic>,
              currentUid ?? '',
            ),
          )
          .toList();
    });
  }

  Future<List<Message>> fetchMessages(
    String conversationId, {
    int limit = 50,
    Timestamp? before,
  }) async {
    Query q = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(limit);

    if (before != null) q = q.startAfter([before]);

    final snapshot = await q.get();
    final String currentUid = UserService.currentUser?.id ?? '';
    final List<Message> msgs = snapshot.docs
        .map(
          (d) => Message.fromJson(d.data() as Map<String, dynamic>, currentUid),
        )
        .toList();
    return msgs.reversed.toList();
  }

  Stream<List<Map<String, dynamic>>> streamConversationsForUser(String userId) {
    final Query ref = _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true);

    return ref.snapshots().map(
      (snap) => snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        data['id'] = d.id;
        return data;
      }).toList(),
    );
  }

  Future<void> markMessageRead(
    String conversationId,
    String messageId,
    String readerId,
  ) async {
    final DocumentReference msgRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    await msgRef.update({
      'readBy': FieldValue.arrayUnion([readerId]),
    });
  }

  Future<void> deleteConversation(
    String conversationId, {
    bool deleteMessages = false,
  }) async {
    final DocumentReference convoRef = _firestore
        .collection('conversations')
        .doc(conversationId);
    if (deleteMessages) {
      final messagesRef = convoRef.collection('messages');
      final snapshot = await messagesRef.get();
      final WriteBatch batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(convoRef);
      await batch.commit();
    } else {
      await convoRef.delete();
    }
  }
}
