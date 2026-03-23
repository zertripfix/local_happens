import 'package:local_happens/features/events/domain/entities/event.dart';

class EventUiModel {
  final Event event;
  final String cityName;
  final String userName;

  EventUiModel({
    required this.event,
    required this.cityName,
    required this.userName,
  });

  factory EventUiModel.fromEvent(
    Event event,
    String cityName,
    String userName,
  ) {
    return EventUiModel(event: event, cityName: cityName, userName: userName);
  }

  EventUiModel copyWith({Event? event, String? cityName, String? userName}) {
    return EventUiModel(
      event: event ?? this.event,
      cityName: cityName ?? this.cityName,
      userName: userName ?? this.userName,
    );
  }
}
