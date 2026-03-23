import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_happens/features/events/domain/entities/event.dart';
import 'package:local_happens/features/events/domain/entities/event_status.dart';
import 'package:local_happens/features/events/domain/usecases/create_event.dart';
import 'package:local_happens/features/events/domain/usecases/get_or_create_city.dart';
import 'package:local_happens/features/events/domain/usecases/resolve_location_from_coordinates.dart';
import 'package:local_happens/features/events/domain/usecases/upload_event_image.dart';
import 'create_event_state.dart';

class CreateEventCubit extends Cubit<CreateEventState> {
  final ResolveLocationFromCoordinates resolveLocation;
  final GetOrCreateCity getOrCreateCity;
  final CreateEvent createEventUseCase;
  final UploadEventImage uploadEventImage;

  CreateEventCubit({
    required this.resolveLocation,
    required this.getOrCreateCity,
    required this.createEventUseCase,
    required this.uploadEventImage,
  }) : super(CreateEventInitial());

  Future<void> resolveLocationFromCoords(double lat, double lng) async {
    emit(CreateEventLocationLoading());
    try {
      final location = await resolveLocation(lat, lng);
      emit(CreateEventLocationResolved(location));
    } catch (e) {
      emit(CreateEventError('Failed to resolve location: $e'));
    }
  }

  Future<void> submitEvent({
    required String title,
    required String description,
    required String category,
    required DateTime date,
    required double lat,
    required double lng,
    required String address,
    required String cityName,
    required String userId,
    String? imageFilePath,
    String link = '',
  }) async {
    emit(CreateEventSubmitting());
    try {
      String imageUrl = '';
      if (imageFilePath != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await uploadEventImage(imageFilePath, fileName);
      }

      final city = await getOrCreateCity(cityName);

      final event = Event(
        id: '',
        title: title,
        description: description,
        category: category,
        cityId: city.id,
        date: date,
        locationAddress: address,
        latitude: lat,
        longitude: lng,
        imageUrl: imageUrl,
        userId: userId,
        status: EventStatus.pending,
        attendeeIds: [],
      );

      await createEventUseCase(event);
      emit(CreateEventSuccess());
    } catch (e) {
      emit(CreateEventError('Failed to create event: $e'));
    }
  }
}
