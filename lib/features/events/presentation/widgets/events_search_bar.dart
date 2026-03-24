import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_happens/core/constants/app_colors.dart';
import 'package:local_happens/core/constants/app_text_styles.dart';
import 'package:local_happens/features/events/presentation/cubit/events_cubit.dart';
import 'package:local_happens/features/events/presentation/cubit/events_state.dart';
import 'package:local_happens/features/events/presentation/models/events_filter_model.dart';
import 'package:local_happens/features/events/presentation/widgets/events_filter_sheet.dart';

class EventsSearchBar extends StatelessWidget {
  final TextEditingController searchController;

  const EventsSearchBar({
    super.key,
    required this.searchController,
  });

  void _openFiltersSheet(
    BuildContext context, {
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
          initialChildSize: 0.80,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
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
                  searchController.clear();
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
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
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
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  height: 1,
                ),
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                ),
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

            final availableCities = context.read<EventsCubit>().getAllCities();

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
                    context,
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
    );
  }
}
