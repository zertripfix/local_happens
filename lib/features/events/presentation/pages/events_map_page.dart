import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_happens/core/constants/app_colors.dart';
import 'package:local_happens/core/constants/app_text_styles.dart';
import 'package:local_happens/features/events/presentation/cubit/events_cubit.dart';
import 'package:local_happens/features/events/presentation/cubit/events_state.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';
import 'package:local_happens/features/events/presentation/widgets/map_event_card.dart';

class EventsMapPage extends StatefulWidget {
  const EventsMapPage({super.key});

  @override
  State<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends State<EventsMapPage> {
  String? _selectedEventId;

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  List<EventUiModel> _getNearestEvents(
    List<EventUiModel> events,
    String? selectedEventId,
  ) {
    if (events.isEmpty) return [];
    if (selectedEventId == null) return events;

    final selectedEventUiModel = events.cast<EventUiModel?>().firstWhere(
          (eventUiModel) => eventUiModel?.event.id == selectedEventId,
          orElse: () => null,
        );

    if (selectedEventUiModel == null) return events;

    final selectedEvent = selectedEventUiModel.event;

    final sortedEvents = [...events];
    sortedEvents.sort((a, b) {
      final distanceA = _calculateDistance(
        selectedEvent.latitude,
        selectedEvent.longitude,
        a.event.latitude,
        a.event.longitude,
      );

      final distanceB = _calculateDistance(
        selectedEvent.latitude,
        selectedEvent.longitude,
        b.event.latitude,
        b.event.longitude,
      );

      return distanceA.compareTo(distanceB);
    });

    return sortedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<EventsCubit, EventsState>(
          builder: (context, state) {
            if (state is EventsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is EventsLoaded) {
              final selectedId =
                  _selectedEventId ??
                  (state.events.isNotEmpty ? state.events.first.event.id : null);

              final nearestEvents = _getNearestEvents(state.events, selectedId);

              final markers = state.events.map((eventUiModel) {
                final isSelected = eventUiModel.event.id == selectedId;

                return Marker(
                  markerId: MarkerId(eventUiModel.event.id),
                  position: LatLng(
                    eventUiModel.event.latitude,
                    eventUiModel.event.longitude,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    isSelected
                        ? BitmapDescriptor.hueRed
                        : BitmapDescriptor.hueOrange,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedEventId = eventUiModel.event.id;
                    });
                  },
                  infoWindow: InfoWindow(
                    title: eventUiModel.event.title,
                    snippet: eventUiModel.event.locationAddress,
                    onTap: () {
                      context.push('/events/${eventUiModel.event.id}');
                    },
                  ),
                );
              }).toSet();

              return Stack(
                children: [
                  GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(50.4501, 30.5234),
                      zoom: 12,
                    ),
                    markers: markers,
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.30,
                    minChildSize: 0.22,
                    maxChildSize: 0.90,
                    snap: true,
                    snapSizes: const [0.30, 0.55, 0.90],
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, -1),
                              blurRadius: 2,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(24, 0, 16, 16),
                                itemCount: nearestEvents.length + 1,
                                separatorBuilder: (_, index) {
                                  if (index == 0) {
                                    return const SizedBox(height: 24);
                                  }
                                  return const SizedBox(height: 8);
                                },
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return Text(
                                      'Найближчі події (${nearestEvents.length})',
                                      style: AppTextStyles.title,
                                    );
                                  }

                                  final eventUiModel = nearestEvents[index - 1];
                                  return MapEventCard(
                                    event: eventUiModel.event,
                                    cityName: eventUiModel.cityName,
                                    onTap: () {
                                      setState(() {
                                        _selectedEventId = eventUiModel.event.id;
                                      });
                                      context.push('/events/${eventUiModel.event.id}');
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }

            return const Center(child: Text('No events'));
          },
        ),
      ),
    );
  }
}