
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityLogService {
  final _logs =
      FirebaseFirestore.instance.collection('activity_logs');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLogs() {
    return _logs.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> record({
    required String action,
    required String description,
    String targetId = '',
  }) async {
    final admin = FirebaseAuth.instance.currentUser;
    if (admin == null) return;

    await _logs.add({
      'action': action,
      'description': description,
      'adminEmail': admin.email ?? 'Admin',
      'targetId': targetId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Logging failures must not interrupt authentication or CRUD.
  Future<void> recordSafely({
    required String action,
    required String description,
    String targetId = '',
  }) async {
    try {
      await record(
        action: action,
        description: description,
        targetId: targetId,
      );
    } catch (e) {
      // Logging is secondary to the user's main operation.
      print('Activity log failed: $e');
    }
  }
}
