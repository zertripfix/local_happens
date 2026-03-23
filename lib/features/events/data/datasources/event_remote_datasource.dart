import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:local_happens/features/events/data/models/event_model.dart';
import 'package:local_happens/features/events/domain/entities/event_status.dart';

abstract class EventRemoteDatasource {
  Stream<List<EventModel>> getEventsStream();
  Future<EventModel> createEvent(EventModel event);
  Future<EventModel> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
  Future<List<EventModel>> filterEvents(String category);
  Future<EventModel> getEventById(String id);
  Stream<List<EventModel>> getUserEventsStream(String userId);
  Stream<List<EventModel>> getEventsStreamByStatus(EventStatus status);
  Future<void> updateEventStatus(String id, EventStatus status);
  Future<String> uploadImage(String filePath, String fileName);
  Future<void> addUserToAttendees(String eventId, String userId);
}

class EventRemoteDatasourceImpl implements EventRemoteDatasource {
  final FirebaseFirestore firestore;
  EventRemoteDatasourceImpl({required this.firestore});

  @override
  Stream<List<EventModel>> getEventsStream() {
    return firestore
        .collection('events')
        .where('status', isEqualTo: EventStatus.approved.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    await firestore.collection('events').add(event.toJson());
    return event;
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    await firestore.collection('events').doc(event.id).update(event.toJson());
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await firestore.collection('events').doc(id).delete();
  }

  @override
  Future<List<EventModel>> filterEvents(String category) async {
    final snapshot = await firestore
        .collection('events')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }

  @override
  Future<EventModel> getEventById(String id) async {
    final snapshot = await firestore.collection('events').doc(id).get();
    return EventModel.fromFirestore(snapshot);
  }

  @override
  Stream<List<EventModel>> getUserEventsStream(String userId) {
    return firestore
        .collection('events')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<EventModel>> getEventsStreamByStatus(EventStatus status) {
    return firestore
        .collection('events')
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> updateEventStatus(String id, EventStatus status) async {
    await firestore.collection('events').doc(id).update({
      'status': status.name,
    });
  }

  @override
  Future<String> uploadImage(String filePath, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('event_images')
        .child(fileName);
    final uploadTask = ref.putFile(File(filePath));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Future<void> addUserToAttendees(String eventId, String userId) async {
    final eventRef = firestore.collection('events').doc(eventId);

    // транзакція, щоб уникнути гонок (race condition) при паралельних кліках
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventRef);
      if (!snapshot.exists) return;

      final currentAttendees = List<String>.from(
        snapshot.get('attendeeIds') ?? [],
      );
      if (!currentAttendees.contains(userId)) {
        currentAttendees.add(userId);
        transaction.update(eventRef, {'attendeeIds': currentAttendees});
      }
    });
  }
}
