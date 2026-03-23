import '../entities/event.dart';
import '../entities/event_status.dart';

abstract class EventRepository {
  Stream<List<Event>> getEventsStream();
  Future<Event> getEventById(String id);
  Future<Event> createEvent(Event event);
  Future<Event> updateEvent(Event event);
  Future<void> deleteEvent(Event event);
  Future<List<Event>> filterEvents(String query);
  Stream<List<Event>> getUserEventsStream(String userId);
  Stream<List<Event>> getEventsStreamByStatus(EventStatus status);
  Future<void> updateEventStatus(String id, EventStatus status);
  Future<String> uploadImage(String filePath, String fileName);
  Future<void> addUserToAttendees(String eventId, String userId);
  Future<void> removeUserFromAttendees(String eventId, String userId);
}
