import 'package:equatable/equatable.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';
import 'package:local_happens/features/events/presentation/models/events_filter_model.dart';


abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<EventUiModel> events;

  final EventsFilterModel filters;

  const EventsLoaded({
    required this.events, 
    this.filters = const EventsFilterModel(),
    });

    EventsLoaded copyWith({
      List<EventUiModel>? events,
      EventsFilterModel? filters,
    }){
      return EventsLoaded(
        events: events ?? this.events,
        filters: filters ?? this.filters,
        );
    }

  @override
  List<Object?> get props => [events, filters];
}


class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object?> get props => [message];
}
