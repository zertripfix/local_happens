import 'package:equatable/equatable.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';

abstract class EventDetailsState extends Equatable {
  const EventDetailsState();

  @override
  List<Object?> get props => [];
}

class EventDetailsInitial extends EventDetailsState {}

class EventDetailsLoading extends EventDetailsState {}

class EventDetailsLoaded extends EventDetailsState {
  final EventUiModel event;

  const EventDetailsLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventDetailsError extends EventDetailsState {
  final String message;

  const EventDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

// attendance
class AttendanceMarked extends EventDetailsState {}

class AttendanceError extends EventDetailsState {
  final String message;
  AttendanceError(this.message);
}
