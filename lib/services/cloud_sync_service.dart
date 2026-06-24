import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'storage_service.dart';

class CloudSyncService {
  CloudSyncService(this._storage);

  static const collectionName = 'WordSearch';

  final StorageService _storage;
  final _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(collectionName).doc(uid);

  Future<void> pushSave(String uid) async {
    try {
      final data = _storage.exportSnapshot();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _doc(uid).set(data, SetOptions(merge: true));
    } catch (e, st) {
      debugPrint('CloudSync push failed: $e\n$st');
    }
  }

  Future<bool> pullSave(String uid) async {
    try {
      final snap = await _doc(uid).get();
      if (!snap.exists || snap.data() == null) return false;
      await _storage.importSnapshot(snap.data()!);
      return true;
    } catch (e, st) {
      debugPrint('CloudSync pull failed: $e\n$st');
      return false;
    }
  }

  Stream<bool> watchConnection(String uid) {
    return _doc(uid).snapshots().map((snap) => snap.exists);
  }
}
