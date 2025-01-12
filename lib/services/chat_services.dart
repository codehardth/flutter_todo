import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConstant {
  static const String collectionChatroom = 'chatrooms';
  static const String collectionMessage = 'messages';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldText = 'text';
  static const String fieldUserId = 'userId';
  static const int paginationSize = 10;
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ดึงข้อความพร้อม Pagination (ครั้งละ 10 ข้อความ)
  Future<List<QueryDocumentSnapshot>> fetchMessages(
    String chatRoomId, {
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection(ChatConstant.collectionChatroom)
        .doc(chatRoomId)
        .collection(ChatConstant.collectionMessage)
        .orderBy(
          ChatConstant.fieldTimestamp,
          descending: true,
        )
        .limit(ChatConstant.paginationSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs;
  }

  /// รับข้อความใหม่แบบเรียลไทม์
  Stream<List<DocumentSnapshot>> getMessageStream(String chatRoomId) {
    return _firestore
        .collection(ChatConstant.collectionChatroom)
        .doc(chatRoomId)
        .collection(ChatConstant.collectionMessage)
        .orderBy(
          ChatConstant.fieldTimestamp,
          descending: true,
        )
        .limit(ChatConstant.paginationSize)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// ส่งข้อความใหม่
  Future<void> sendMessage(
    String chatRoomId,
    String text,
    String userId,
  ) async {
    final message = {
      ChatConstant.fieldText: text,
      ChatConstant.fieldTimestamp: FieldValue.serverTimestamp(),
      ChatConstant.fieldUserId: userId,
    };

    await _firestore
        .collection(ChatConstant.collectionChatroom)
        .doc(chatRoomId)
        .collection(ChatConstant.collectionMessage)
        .add(message);
  }
}
