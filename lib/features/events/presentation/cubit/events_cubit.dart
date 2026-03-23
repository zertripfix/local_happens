import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_happens/features/events/domain/usecases/delete_event.dart';
import 'package:local_happens/features/events/domain/usecases/get_cities_by_ids.dart';
import 'package:local_happens/features/events/domain/usecases/get_users_by_ids.dart';
import 'package:local_happens/features/events/domain/usecases/update_event.dart';
import 'package:local_happens/features/events/domain/entities/event.dart';
import 'package:local_happens/features/events/domain/usecases/create_event.dart';
import 'package:local_happens/features/events/domain/usecases/get_events_stream.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';
import 'package:local_happens/features/events/presentation/models/events_filter_model.dart';
import 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final GetEventsStream getEvents;
  final CreateEvent createEventUseCase;
  final UpdateEvent updateEventUseCase;
  final DeleteEvent deleteEventUseCase;
  final GetUsersByIds getUsersByIdsUseCase;
  final GetCitiesByIds getCitiesByIdsUseCase;

  StreamSubscription? _subscription;

  List<EventUiModel> _allEvents = [];
  EventsFilterModel _activeFilters = const EventsFilterModel();

  EventsCubit({
    required this.getEvents,
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
    required this.getUsersByIdsUseCase,
    required this.getCitiesByIdsUseCase,
  }) : super(EventsInitial());

  List<EventUiModel> _applyFilters(){
    List<EventUiModel> filteredEvents = List.from(_allEvents);

    if (_activeFilters.searchQuery.trim().isNotEmpty){
      final query = _activeFilters.searchQuery.trim().toLowerCase();

      filteredEvents = filteredEvents.where((eventUiModel){
        final event = eventUiModel.event;
        final title = event.title.toLowerCase();
        final category = event.category.toLowerCase();
        final address = event.locationAddress.toLowerCase();
        final cityName = eventUiModel.cityName.toLowerCase();

        return title.contains(query) ||
            category.contains(query) ||
            address.contains(query) ||
            cityName.contains(query);
      }).toList();
    }

    if (_activeFilters.selectedCategory != 'Усі'){
      filteredEvents = filteredEvents.where((eventUiModel){
        return eventUiModel.event.category == _activeFilters.selectedCategory;
      }).toList();
    }

    // city filter (chip)
    if (_activeFilters.selectedCity != null &&
        _activeFilters.selectedCity!.trim().isNotEmpty) {
      final selectedCity = _activeFilters.selectedCity!.toLowerCase();

      filteredEvents = filteredEvents.where((eventUi) {
        return eventUi.cityName.toLowerCase() == selectedCity;
      }).toList();
    }

    // custom city (input)
    if (_activeFilters.selectedCustomCity != null &&
        _activeFilters.selectedCustomCity!.trim().isNotEmpty) {
      final customCity = _activeFilters.selectedCustomCity!.toLowerCase();

      filteredEvents = filteredEvents.where((eventUi) {
        return eventUi.cityName.toLowerCase().contains(customCity);
      }).toList();
    }

    if (_activeFilters.selectedTimeFilter != EventsTimeFilter.none &&
        _activeFilters.selectedTimeFilter != EventsTimeFilter.custom) {

      filteredEvents = filteredEvents.where((eventUi) {
        final eventDate = eventUi.event.date; 
        return _matchesTimeFilter(
          eventDate,
          _activeFilters.selectedTimeFilter,
        );
      }).toList();
    }

    if (_activeFilters.selectedTimeFilter == EventsTimeFilter.custom) {
      final dateFrom = _activeFilters.dateFrom;
      final dateTo = _activeFilters.dateTo;

      filteredEvents = filteredEvents.where((eventUi) {
        final eventDate = DateTime(
          eventUi.event.date.year,
          eventUi.event.date.month,
          eventUi.event.date.day,
        );

        if (dateFrom != null && dateTo != null) {
          final normalizedFrom = DateTime(
            dateFrom.year,
            dateFrom.month,
            dateFrom.day,
          );
          final normalizedTo = DateTime(
            dateTo.year,
            dateTo.month,
            dateTo.day,
          );

          return !eventDate.isBefore(normalizedFrom) &&
              !eventDate.isAfter(normalizedTo);
        }

        if (dateFrom != null) {
          final normalizedFrom = DateTime(
            dateFrom.year,
            dateFrom.month,
            dateFrom.day,
          );

          return !eventDate.isBefore(normalizedFrom);
        }

        if (dateTo != null) {
          final normalizedTo = DateTime(
            dateTo.year,
            dateTo.month,
            dateTo.day,
          );

          return !eventDate.isAfter(normalizedTo);
        }

        return true;
      }).toList();
    }
    return filteredEvents;
  }

  List<String> getAllCities() {
    return _allEvents
        .map((eventUiModel) => eventUiModel.cityName)
        .toSet()
        .toList();
  }

  void subscribeEvents() {
    emit(EventsLoading());
    _subscription?.cancel();
    _subscription = getEvents().listen((events) async {
      if (events.isEmpty) {
        _allEvents = [];
        emit(
          EventsLoaded(
            events: [],
            filters: _activeFilters,
          ),
        );
        return;
      }
      final citiesIds = events.map((event) => event.cityId).toSet();
      final usersIds = events.map((event) => event.userId).toSet();
      
      final cities = await getCitiesByIdsUseCase(citiesIds);
      final users = await getUsersByIdsUseCase(usersIds);
      final eventsUiModel = events.map((event) {
        return EventUiModel.fromEvent(
          event,
          cities.firstWhere((city) => city.id == event.cityId).name,
          users.firstWhere((user) => user.id == event.userId).name,
        );
      }).toList();

      _allEvents = eventsUiModel;

      emit(
        EventsLoaded(
          events: _applyFilters(),
          filters: _activeFilters,
        ),
      );
    }, onError: (error) => emit(EventsError(error.toString())));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  bool _matchesTimeFilter(
    DateTime eventDate,
    EventsTimeFilter filter,
  ) {
    if (filter == EventsTimeFilter.none) {
      return true;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final normalizedEventDate = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
    );

    switch (filter) {
      case EventsTimeFilter.today:
        return _isSameDate(normalizedEventDate, today);

      case EventsTimeFilter.tomorrow:
        return _isSameDate(normalizedEventDate, tomorrow);

      case EventsTimeFilter.weekend:
        final daysUntilSaturday = (DateTime.saturday - today.weekday + 7) % 7;
        final thisSaturday = today.add(Duration(days: daysUntilSaturday));
        final thisSunday = thisSaturday.add(const Duration(days: 1));

        return _isSameDate(normalizedEventDate, thisSaturday) ||
            _isSameDate(normalizedEventDate, thisSunday);

      case EventsTimeFilter.week:
        final weekStart = _startOfWeek(today);
        final weekEnd = weekStart.add(const Duration(days: 6));

        return !normalizedEventDate.isBefore(weekStart) &&
            !normalizedEventDate.isAfter(weekEnd);

      case EventsTimeFilter.month:
        return normalizedEventDate.year == today.year &&
            normalizedEventDate.month == today.month;

      case EventsTimeFilter.custom:
        return true;

      case EventsTimeFilter.none:
        return true;
    }
  }

  Future<void> filterEvents(String query) async {
    try {
      _activeFilters = _activeFilters.copyWith(searchQuery: query);
      emit(
        EventsLoaded(
          events: _applyFilters(),
          filters: _activeFilters,
        ),
      );
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> selectCategory(String category) async{
    try {
      _activeFilters = _activeFilters.copyWith(selectedCategory: category);
      emit(
        EventsLoaded(
          events: _applyFilters(),
          filters: _activeFilters,
        ),
      );
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> applyFilters(EventsFilterModel filters) async {
    try {
      _activeFilters = filters;
      emit(
        EventsLoaded(
          events: _applyFilters(),
          filters: _activeFilters,
        ),
      );
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> resetFilters() async {
    try {
      _activeFilters = const EventsFilterModel();
      emit(
        EventsLoaded(
          events: _applyFilters(),
          filters: _activeFilters,
        ),
      );
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> createEvent(Event event) async {
    try {
      await createEventUseCase(event);
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      await updateEventUseCase(event);
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> deleteEvent(Event event) async {
    try {
      await deleteEventUseCase(event);
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }
}
