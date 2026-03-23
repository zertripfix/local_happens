import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_happens/core/constants/app_colors.dart';
import 'package:local_happens/core/constants/app_text_styles.dart';
import 'package:local_happens/features/events/presentation/cubit/events_cubit.dart';
import 'package:local_happens/features/events/presentation/cubit/events_state.dart';
import 'package:local_happens/features/events/presentation/models/events_filter_model.dart';
import 'package:local_happens/features/events/presentation/widgets/event_card_widget.dart';
import 'package:local_happens/features/events/presentation/widgets/events_filter_sheet.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Усі',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
    },
    {'name': 'Музика', 'icon': Icons.music_note, 'color': Colors.blue},
    {'name': 'Спорт', 'icon': Icons.bolt, 'color': Colors.amber},
    {'name': 'Їжа', 'icon': Icons.restaurant, 'color': Colors.red},
    {'name': 'Мистецтво', 'icon': Icons.palette, 'color': Colors.purple},
    {'name': 'Освіта', 'icon': Icons.school, 'color': Colors.green},
    {'name': 'Технології', 'icon': Icons.computer, 'color': Colors.grey},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFiltersSheet({
    required EventsFilterModel currentFilters,
    required List<String> availableCities,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: EventsFilterSheet(
                initialFilters: currentFilters,
                availableCities: availableCities,
                scrollController: scrollController,
                onApply: (filters) {
                  context.read<EventsCubit>().applyFilters(filters);
                  Navigator.pop(context);
                },
                onReset: () {
                  _searchController.clear();
                  context.read<EventsCubit>().resetFilters();
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isLandscape ? 20 : 56),
              const Text(
                'LocalHappens',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 2),
              const Text(
                'Знаходь цікаве поруч',
                style: AppTextStyles.value,
              ),
              SizedBox(height: isLandscape ? 16 : 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          context.read<EventsCubit>().filterEvents(value);
                        },
                        textAlignVertical: TextAlignVertical.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.foreground,
                          height: 1,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Шукати події...',
                          hintStyle:
                              AppTextStyles.bodySmall.copyWith(height: 1),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.mutedForeground,
                            size: 22,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 48,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<EventsCubit, EventsState>(
                    builder: (context, state) {
                      final currentFilters = state is EventsLoaded
                          ? state.filters
                          : const EventsFilterModel();

                      final availableCities =
                          context.read<EventsCubit>().getAllCities();

                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            _openFiltersSheet(
                              currentFilters: currentFilters,
                              availableCities: availableCities,
                            );
                          },
                          icon: const Icon(
                            Icons.tune,
                            color: AppColors.foreground,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: isLandscape ? 16 : 24),
              BlocBuilder<EventsCubit, EventsState>(
                builder: (context, state) {
                  final selectedCategory = state is EventsLoaded
                      ? state.filters.selectedCategory
                      : 'Усі';

                  return SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = selectedCategory == category['name'];

                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == _categories.length - 1 ? 0 : 8,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              context.read<EventsCubit>().selectCategory(
                                    category['name'],
                                  );
                            },
                            child: Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.secondaryBackground,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    category['icon'],
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.foreground,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category['name'],
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: isLandscape ? 20 : 32),
              Expanded(
                child: BlocBuilder<EventsCubit, EventsState>(
                  builder: (context, state) {
                    if (state is EventsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is EventsLoaded &&
                        state.events.isNotEmpty) {
                      return GridView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.56,
                        ),
                        itemCount: state.events.length,
                        itemBuilder: (context, index) {
                          final eventUiModel = state.events[index];
                          return EventCard(event: eventUiModel.event);
                        },
                      );
                    } else if (state is EventsError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Подій не знайдено',
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}