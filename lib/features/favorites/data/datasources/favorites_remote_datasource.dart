import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_happens/features/events/data/models/event_model.dart';
import 'package:local_happens/features/events/domain/entities/event.dart';

abstract class FavoritesRemoteDatasource {
  Stream<List<Event>> getFavoritesStream();
  Future<bool> isFavorite(String eventId);
  Future<void> addFavorite(String eventId);
  Future<void> removeFavorite(String eventId);
}

class FavoritesRemoteDatasourceImpl implements FavoritesRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  FavoritesRemoteDatasourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String? get _userId {
    return firebaseAuth.currentUser?.uid;
  }

  @override
  Stream<List<Event>> getFavoritesStream() {
    final uid = _userId;
    if (uid == null) {
      return Stream.value(<Event>[]);
    }

    return firestore.collection('users').doc(uid).collection('favorites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
      if (favoriteIds.isEmpty) {
        return <Event>[];
      }

      final eventsById = <String, Event>{};
      const chunkSize = 10;

      for (var index = 0; index < favoriteIds.length; index += chunkSize) {
        final chunk = favoriteIds.skip(index).take(chunkSize).toList();
        final eventsSnapshot = await firestore
            .collection('events')
            .where(FieldPath.documentId, whereIn: chunk)
            .where('status', isEqualTo: 'approved')
            .get();

        for (final doc in eventsSnapshot.docs) {
          final event = EventModel.fromFirestore(doc).toEntity();
          eventsById[event.id] = event;
        }
      }

      return favoriteIds
          .where(eventsById.containsKey)
          .map((id) => eventsById[id]!)
          .toList();
    });
  }

  @override
  Future<bool> isFavorite(String eventId) async {
    final uid = _userId;
    if (uid == null) return false;

    final favoriteDoc = await firestore.collection('users').doc(uid).collection('favorites').doc(eventId).get();
    return favoriteDoc.exists;
  }

  @override
  Future<void> addFavorite(String eventId) async {
    final uid = _userId;
    if (uid == null) throw Exception('User is not authenticated');

    await firestore.collection('users').doc(uid).collection('favorites').doc(eventId).set({
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeFavorite(String eventId) async {
    final uid = _userId;
    if (uid == null) throw Exception('User is not authenticated');

    await firestore.collection('users').doc(uid).collection('favorites').doc(eventId).delete();
  }
}
