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
        'lastMessage': initialText ?? '',
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
    batch.update(convoRef, {
      'lastMessage': text,
      'lastMessageSenderId': senderId,
      'lastMessageId': newMsgRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });

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
        .where('participants', arrayContains: userId);

    return ref.snapshots().map((snap) {
      final List<Map<String, dynamic>> mapped = snap.docs.map((d) {
        final raw = d.data() as Map<String, dynamic>;
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
        data['id'] = d.id;

        try {
          final partsRaw = raw['participants'] as List<dynamic>?;
          if (partsRaw != null) {
            final List<String> normalized = partsRaw
                .map((p) {
                  if (p == null) return '';
                  if (p is String) return p;
                  if (p is DocumentReference) return p.id;
                  if (p is Map && p['id'] != null) return p['id'].toString();
                  return p.toString();
                })
                .where((s) => s.isNotEmpty)
                .toList();
            data['participants'] = normalized;
          }
        } catch (e) {
          print(
            'ChatService: failed to normalize participants for convo ${d.id}: $e',
          );
        }

        return data;
      }).toList();

      // Sort client-side by updatedAt (newest first). If updatedAt missing, treat as epoch.
      mapped.sort((a, b) {
        final aTs = a['updatedAt'];
        final bTs = b['updatedAt'];
        int aMillis = 0;
        int bMillis = 0;
        try {
          if (aTs is Timestamp)
            aMillis = aTs.millisecondsSinceEpoch;
          else if (aTs is DateTime)
            aMillis = aTs.millisecondsSinceEpoch;
        } catch (_) {}
        try {
          if (bTs is Timestamp)
            bMillis = bTs.millisecondsSinceEpoch;
          else if (bTs is DateTime)
            bMillis = bTs.millisecondsSinceEpoch;
        } catch (_) {}
        return bMillis.compareTo(aMillis);
      });

      return mapped;
    });
  }

  /// Returns the stored `lastMessage` string for a conversation.
  /// Returns an empty string when the conversation doesn't exist or no lastMessage.
  Future<String> getConversationLastMessage(String conversationId) async {
    final DocumentReference convoRef = _firestore
        .collection('conversations')
        .doc(conversationId);
    final snap = await convoRef.get();
    if (!snap.exists) return '';
    final data = snap.data() as Map<String, dynamic>?;
    if (data == null) return '';
    return (data['lastMessage'] as String?) ?? '';
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
