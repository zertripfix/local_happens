import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_status.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDatasource remoteDatasource;
  final FirebaseFirestore firestore;

  EventRepositoryImpl({
    required this.remoteDatasource,
    required this.firestore,
  });

  @override
  Stream<List<Event>> getEventsStream() {
    final modelsStream = remoteDatasource.getEventsStream();
    return modelsStream.map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<Event> createEvent(Event event) async {
    final eventModel = EventModel.fromEntity(event);
    final createdModel = await remoteDatasource.createEvent(eventModel);
    return createdModel.toEntity();
  }

  @override
  Future<void> deleteEvent(Event event) async {
    await remoteDatasource.deleteEvent(event.id);
  }

  @override
  Future<Event> getEventById(String id) async {
    final model = await remoteDatasource.getEventById(id);
    return model.toEntity();
  }

  @override
  Future<Event> updateEvent(Event event) async {
    final eventModel = EventModel.fromEntity(event);
    final updatedModel = await remoteDatasource.updateEvent(eventModel);
    return updatedModel.toEntity();
  }

  @override
  Future<List<Event>> filterEvents(String query) async {
    final models = await remoteDatasource.filterEvents(query);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<List<Event>> getUserEventsStream(String userId) {
    final modelsStream = remoteDatasource.getUserEventsStream(userId);
    return modelsStream.map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Stream<List<Event>> getEventsStreamByStatus(EventStatus status) {
    final modelsStream = remoteDatasource.getEventsStreamByStatus(status);
    return modelsStream.map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<void> updateEventStatus(String id, EventStatus status) async {
    await remoteDatasource.updateEventStatus(id, status);
  }

  @override
  Future<String> uploadImage(String filePath, String fileName) {
    return remoteDatasource.uploadImage(filePath, fileName);
  }

  @override
  Future<void> addUserToAttendees(String eventId, String userId) async {
    await firestore.collection('events').doc(eventId).update({
      'attendeeIds': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> removeUserFromAttendees(String eventId, String userId) async {
    await firestore.collection('events').doc(eventId).update({
      'attendeeIds': FieldValue.arrayRemove([userId]),
    });
  }
}
