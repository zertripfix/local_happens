import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_happens/core/constants/app_colors.dart';
import 'package:local_happens/core/constants/app_text_styles.dart';
import 'package:local_happens/features/events/presentation/cubit/events_cubit.dart';
import 'package:local_happens/features/events/presentation/cubit/events_state.dart';

class EventsCategoriesList extends StatelessWidget {
  const EventsCategoriesList({super.key});

  static const List<Map<String, dynamic>> _categories = [
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
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
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
    );
  }
}
