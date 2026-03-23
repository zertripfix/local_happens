import 'package:equatable/equatable.dart';

enum EventsTimeFilter{
  none,
  today,
  tomorrow,
  weekend,
  week,
  month,
  custom,
}

class EventsFilterModel extends Equatable{
  final String searchQuery;
  final String selectedCategory;
  final String? selectedCity;
  final String? selectedCustomCity;
  final EventsTimeFilter selectedTimeFilter;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const EventsFilterModel({
    this.searchQuery = '',
    this.selectedCategory = 'Усі',
    this.selectedCity,
    this.selectedCustomCity,
    this.selectedTimeFilter = EventsTimeFilter.none,
    this.dateFrom,
    this.dateTo,
  });

  EventsFilterModel copyWith({
    String? searchQuery,
    String? selectedCategory,
    String? selectedCity,
    String? selectedCustomCity,
    EventsTimeFilter? selectedTimeFilter,
    DateTime? dateFrom,
    DateTime? dateTo,

    bool clearSelectedCity = false,
    bool clearSelectedCustomCity = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }){
    return EventsFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,

      selectedCity: clearSelectedCity ? null : (selectedCity ?? this.selectedCity),

      selectedCustomCity: clearSelectedCustomCity
          ? null
          : (selectedCustomCity ?? this.selectedCustomCity),

      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,

      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
    );
  }

  EventsFilterModel reset(){
    return const EventsFilterModel();
  }


  bool get hasActiveFilters {
    return searchQuery.trim().isNotEmpty ||
        selectedCategory != 'Усі' ||
        selectedCity != null ||
        selectedCustomCity != null ||
        selectedTimeFilter != EventsTimeFilter.none ||
        dateFrom != null ||
        dateTo != null;
  }

  @override
  List<Object?> get props => [
        searchQuery,
        selectedCategory,
        selectedCity,
        selectedCustomCity,
        selectedTimeFilter,
        dateFrom,
        dateTo,
      ];


}