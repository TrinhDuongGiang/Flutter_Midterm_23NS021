
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import 'activity_log_service.dart';

class UserService {
  final _users =
      FirebaseFirestore.instance.collection('users');

  final _logs = ActivityLogService();

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return _users.snapshots();
  }

  String _hashPassword(String password) {
    final random = Random.secure();

    final salt = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    );

    final saltText = base64Encode(salt);

    final hash = sha256
        .convert([...salt, ...utf8.encode(password)])
        .toString();

    return 'sha256:$saltText:$hash';
  }

  String _encodeImage(Uint8List? bytes) {
    if (bytes == null) return '';

    if (bytes.length > 700 * 1024) {
      throw ArgumentError(
        'Image must be smaller than 700 KB.',
      );
    }

    return base64Encode(bytes);
  }

  Future<void> addUser({
    required String hoten,
    required String email,
    required String password,
    Uint8List? imageBytes,
  }) async {
    final doc = await _users.add({
      'hoten': hoten.trim(),
      'email': email.trim(),
      'matkhau': _hashPassword(password),
      'hinhanh': _encodeImage(imageBytes),
    });

    await _logs.recordSafely(
      action: 'CREATE',
      description: 'Added user: ${hoten.trim()}',
      targetId: doc.id,
    );
  }

  Future<void> updateUser({
    required String id,
    required String hoten,
    required String email,
    String? password,
    Uint8List? imageBytes,
    bool removeImage = false,
  }) async {
    final data = <String, dynamic>{
      'hoten': hoten.trim(),
      'email': email.trim(),
    };

    if (password != null && password.isNotEmpty) {
      data['matkhau'] = _hashPassword(password);
    }

    if (removeImage) {
      data['hinhanh'] = '';
    } else if (imageBytes != null) {
      data['hinhanh'] = _encodeImage(imageBytes);
    }

    await _users.doc(id).update(data);

    await _logs.recordSafely(
      action: 'UPDATE',
      description: 'Updated user: ${hoten.trim()}',
      targetId: id,
    );
  }

  Future<void> deleteUser(String id) async {
    final snapshot = await _users.doc(id).get();
    final name =
        (snapshot.data()?['hoten'] ?? 'Unknown user').toString();

    await _users.doc(id).delete();

    await _logs.recordSafely(
      action: 'DELETE',
      description: 'Deleted user: $name',
      targetId: id,
    );
  }
}
