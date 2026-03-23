import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:local_happens/core/utils/date_formatter.dart';
import 'package:local_happens/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:local_happens/features/auth/domain/entities/user_role.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_state.dart';
import 'package:local_happens/features/events/domain/entities/event_status.dart';
import 'package:local_happens/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:local_happens/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_happens/features/events/presentation/cubit/event_details_cubit.dart';
import 'package:local_happens/features/events/presentation/cubit/event_details_state.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';
import 'package:local_happens/injection_container.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().checkIsFavorite(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EventDetailsCubit>()..loadEvent(widget.eventId),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<EventDetailsCubit, EventDetailsState>(
          builder: (context, state) {
            if (state is EventDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EventDetailsLoaded) {
              return _buildContent(context, state.event);
            } else if (state is EventDetailsError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EventUiModel uiModel) {
    final event = uiModel.event;
    final timeFormat = DateFormat("HH:mm");
    final authState = context.read<AuthCubit>().state;
    final isAdmin = authState is Authenticated
        ? authState.user.role == UserRole.admin
        : false;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 400,
              leading: const SizedBox.shrink(),
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: event.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.white,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildTag(
                          icon: Icons.music_note,
                          label: event.category,
                          color: Colors.red[50]!,
                          textColor: Colors.red[700]!,
                        ),
                        const SizedBox(width: 12),
                        _buildTag(
                          label: '${event.attendeeIds.length} планують прийти',
                          color: Colors.grey[100]!,
                          textColor: Colors.black87,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildInfoCard(
                      icon: Icons.calendar_today_outlined,
                      title: formatDateWithWeekday(event.date),
                      subtitle: timeFormat.format(event.date),
                    ),

                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.red[400],
                      title: event.locationAddress,
                      subtitle: uiModel.cityName,
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Про подію',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Локація',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 200,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(event.latitude, event.longitude),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('event_location'),
                              position: LatLng(event.latitude, event.longitude),
                            ),
                          },
                          liteModeEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (event.externalUrl != null) {
                                final url = Uri.parse(event.externalUrl!);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A574D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.open_in_new, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Перейти на сайт',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: BlocBuilder<EventDetailsCubit, EventDetailsState>(
                            builder: (context, state) {
                              final authState = context.read<AuthCubit>().state;

                              if (state is EventDetailsLoaded) {
                                final event = state.event.event;

                                final currentUserId = authState is Authenticated
                                    ? authState.user.id
                                    : null;

                                final isAttending =
                                    currentUserId != null &&
                                    event.attendeeIds.contains(currentUserId);

                                return OutlinedButton(
                                  onPressed: authState is Authenticated
                                      ? () {
                                          context
                                              .read<EventDetailsCubit>()
                                              .toggleAttendance(
                                                event.id,
                                                currentUserId!,
                                              );

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                isAttending
                                                    ? 'Ви більше не плануєте йти'
                                                    : 'Гарно провести час!',
                                              ),
                                            ),
                                          );
                                        }
                                      : () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Спочатку увійдіть в акаунт',
                                              ),
                                            ),
                                          );
                                        },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey[300]!),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isAttending
                                            ? Icons.person_remove_outlined
                                            : Icons.person_add_outlined,
                                        size: 20,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAttending ? 'Передумав' : 'Я буду!',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin) ...[
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<AdminCubit>().changeEventStatus(
                                  event.id,
                                  EventStatus.approved,
                                );
                                context.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A574D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Схвалити',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<AdminCubit>().changeEventStatus(
                                  event.id,
                                  EventStatus.rejected,
                                );
                                context.pop();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Відхилити',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          child: _buildFloatingButton(
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
          ),
        ),

        // Favorite button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: BlocConsumer<FavoritesCubit, FavoritesState>(
            listener: (context, state) {
              if (state is FavoritesError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is FavoritesLoading) {
                return _buildFloatingButton(
                  icon: Icons.favorite_border,
                  iconColor: Colors.grey,
                  onPressed: () {}, // кнопка неактивна
                );
              }

              final authState = context.read<AuthCubit>().state;
              final isAuthenticated = authState is Authenticated;
              final isFavorite =
                  isAuthenticated && state.favoriteIds.contains(widget.eventId);

              return _buildFloatingButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: isFavorite ? Colors.redAccent : Colors.black87,
                onPressed: () {
                  if (!isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Увійдіть, щоб мати можливість додавати в "Обране"',
                        ),
                      ),
                    );
                    return;
                  }
                  context.read<FavoritesCubit>().toggleFavorite(widget.eventId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTag({
    IconData? icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label.toLowerCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5),
              ],
            ),
            child: Icon(icon, color: iconColor ?? Colors.grey[600], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    Color iconColor = Colors.black87,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
