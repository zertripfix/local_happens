import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_happens/core/constants/app_colors.dart';
import 'package:local_happens/core/constants/app_text_styles.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.eventUiModel,
  });

  final EventUiModel eventUiModel;

  String _getMonthName(int month) {
    const months = [
      'січ.', 'лют.', 'берез.', 'квіт.', 'трав.', 'черв.',
      'лип.', 'серп.', 'вер.', 'жовт.', 'лист.', 'груд.'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/events/${eventUiModel.event.id}', extra: eventUiModel),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.background.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          AspectRatio(
            aspectRatio: 160 / 178,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: eventUiModel.event.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.secondaryBackground,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.secondaryBackground,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getCategoryIcon(eventUiModel.event.category),
                              const SizedBox(width: 4),
                              Text(
                                eventUiModel.event.category,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${eventUiModel.event.date.day} ${_getMonthName(eventUiModel.event.date.month)}',
                            style: AppTextStyles.dateTitle,
                          ),
                          Text(
                            '${eventUiModel.event.date.hour.toString().padLeft(2, '0')}:${eventUiModel.event.date.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 38,
                    child: Text(
                      eventUiModel.event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          eventUiModel.cityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    switch (category.toLowerCase()) {
      case 'музика':
        iconData = Icons.music_note;
        break;
      case 'спорт':
        iconData = Icons.bolt;
        break;
      case 'їжа':
        iconData = Icons.restaurant;
        break;
      case 'мистецтво':
        iconData = Icons.palette;
        break;
      case 'освіта':
        iconData = Icons.school;
        break;
      case 'технології':
        iconData = Icons.computer;
        break;
      default:
        iconData = Icons.star;
    }
    return Icon(iconData, size: 14, color: Colors.white);
  }
}