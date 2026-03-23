import 'package:equatable/equatable.dart';
import 'package:local_happens/features/events/domain/entities/event_status.dart';

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String cityId;
  final DateTime date;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String userId;
  final EventStatus status;
  final String? externalUrl;
  final List<String> attendeeIds;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.cityId,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.userId,
    required this.status,
    this.externalUrl,
    required this.attendeeIds,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? cityId,
    DateTime? date,
    String? locationAddress,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? userId,
    EventStatus? status,
    String? externalUrl,
    List<String>? attendeeIds,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      cityId: cityId ?? this.cityId,
      date: date ?? this.date,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      externalUrl: externalUrl ?? this.externalUrl,
      attendeeIds: attendeeIds ?? this.attendeeIds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    date,
    category,
    cityId,
    locationAddress,
    latitude,
    longitude,
    imageUrl,
    userId,
    status,
    externalUrl,
    attendeeIds,
  ];
}
