import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_happens/features/admin/presentation/pages/admin_page.dart';
import 'package:local_happens/features/auth/domain/entities/user_role.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_state.dart';
import 'package:local_happens/features/events/presentation/cubit/create_event_cubit.dart';
import 'package:local_happens/features/events/presentation/cubit/event_details_cubit.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';
import 'package:local_happens/features/events/presentation/pages/events_map_page.dart';
import 'package:local_happens/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:local_happens/injection_container.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/events/presentation/pages/events_page.dart';
import '../features/events/presentation/pages/event_details_page.dart';
import '../features/events/presentation/pages/create_event_page.dart';
import '../features/favorites/presentation/pages/favorites_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../presentation/pages/main_navigation_page.dart';
import '../presentation/pages/splash_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/events/create',
        builder: (context, state) => BlocProvider<CreateEventCubit>(
          create: (_) => sl<CreateEventCubit>(),
          child: const CreateEventPage(),
        ),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) {
          final extra = state.extra;

          late final EventUiModel eventUiModel;
          late final bool isFromAdminEventCard;

          if (extra is Map<String, dynamic>) {
            eventUiModel = extra['eventUiModel'] as EventUiModel;
            isFromAdminEventCard =
                extra['isFromAdminEventCard'] as bool? ?? false;
          } else if (extra is EventUiModel) {
            eventUiModel = extra;
            isFromAdminEventCard = false;
          } else {
            return const Scaffold(
              body: Center(child: Text('Подія не знайдена')),
            );
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider<EventDetailsCubit>(
                create: (_) => sl<EventDetailsCubit>(),
              ),
              BlocProvider<FavoritesCubit>(create: (_) => sl<FavoritesCubit>()),
            ],
            child: EventDetailsPage(
              eventUiModel: eventUiModel,
              isFromAdminEventCard: isFromAdminEventCard,
            ),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                builder: (context, state) => const EventsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const EventsMapPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminPage(),
                redirect: (context, state) {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is! Authenticated ||
                      authState.user.role != UserRole.admin) {
                    return '/events';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
