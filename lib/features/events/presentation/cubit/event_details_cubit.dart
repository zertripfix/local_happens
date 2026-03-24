import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_happens/features/events/domain/usecases/add_user_to_attendees.dart';
import 'package:local_happens/features/events/domain/usecases/get_cities_by_ids.dart';
import 'package:local_happens/features/events/domain/usecases/get_event_by_id.dart';
import 'package:local_happens/features/events/domain/usecases/get_users_by_ids.dart';
import 'package:local_happens/features/events/domain/usecases/remove_user_from_attendees.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';
import 'event_details_state.dart';

class EventDetailsCubit extends Cubit<EventDetailsState> {
  final GetEventById getEventByIdUseCase;
  final GetUsersByIds getUsersByIdsUseCase;
  final GetCitiesByIds getCitiesByIdsUseCase;
  final AddUserToAttendeesUseCase addUserToAttendeesUseCase;
  final RemoveUserFromAttendeesUseCase removeUserFromAttendeesUseCase;

  EventDetailsCubit({
    required this.getEventByIdUseCase,
    required this.getUsersByIdsUseCase,
    required this.getCitiesByIdsUseCase,
    required this.addUserToAttendeesUseCase,
    required this.removeUserFromAttendeesUseCase,
  }) : super(EventDetailsInitial());

  void setEvent(EventUiModel eventUiModel) {
    emit(EventDetailsLoaded(eventUiModel));
  }

  Future<void> toggleAttendance(String eventId, String userId) async {
    final currentState = state;

    if (currentState is EventDetailsLoaded) {
      final uiModel = currentState.event;
      final event = uiModel.event;

      final isAttending = event.attendeeIds.contains(userId);

      try {
        List<String> updatedAttendees;

        if (isAttending) {
          await removeUserFromAttendeesUseCase(eventId, userId);
          updatedAttendees = event.attendeeIds
              .where((id) => id != userId)
              .toList();
        } else {
          await addUserToAttendeesUseCase(eventId, userId);
          updatedAttendees = [...event.attendeeIds, userId];
        }

        // новий event
        final updatedEvent = event.copyWith(attendeeIds: updatedAttendees);

        // новий uiModel
        final updatedUiModel = uiModel.copyWith(event: updatedEvent);

        // новий state
        emit(EventDetailsLoaded(updatedUiModel));
      } catch (e) {
        emit(AttendanceError('Не вдалося змінити участь'));
      }
    }
  }
}
