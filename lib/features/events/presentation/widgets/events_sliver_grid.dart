import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_happens/core/constants/app_text_styles.dart';
import 'package:local_happens/features/events/presentation/cubit/events_cubit.dart';
import 'package:local_happens/features/events/presentation/cubit/events_state.dart';
import 'package:local_happens/features/events/presentation/widgets/event_card_widget.dart';

class EventsSliverGrid extends StatelessWidget {
  const EventsSliverGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is EventsLoaded && state.events.isNotEmpty) {
          return SliverPadding(
            padding: const EdgeInsets.only(bottom: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.56,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final eventUiModel = state.events[index];
                  return EventCard(eventUiModel: eventUiModel);
                },
                childCount: state.events.length,
              ),
            ),
          );
        } else if (state is EventsError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                state.message,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          );
        } else {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Подій не знайдено',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          );
        }
      },
    );
  }
}
