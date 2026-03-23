import 'package:local_happens/features/events/domain/repositories/event_repository.dart';

class RemoveUserFromAttendeesUseCase {
  final EventRepository repository;

  RemoveUserFromAttendeesUseCase(this.repository);

  Future<void> call(String eventId, String userId) async {
    await repository.removeUserFromAttendees(eventId, userId);
  }
}
