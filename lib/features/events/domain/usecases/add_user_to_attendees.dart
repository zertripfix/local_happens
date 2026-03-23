import 'package:local_happens/features/events/domain/repositories/event_repository.dart';

class AddUserToAttendeesUseCase {
  final EventRepository repository;

  AddUserToAttendeesUseCase(this.repository);

  Future<void> call(String eventId, String userId) async {
    await repository.addUserToAttendees(eventId, userId);
  }
}
