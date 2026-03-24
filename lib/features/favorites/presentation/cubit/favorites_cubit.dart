import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_happens/features/events/domain/entities/event.dart';
import 'package:local_happens/features/events/domain/usecases/get_cities_by_ids.dart';
import 'package:local_happens/features/events/domain/usecases/get_users_by_ids.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';
import 'package:local_happens/features/favorites/domain/usecases/add_favorite.dart';
import 'package:local_happens/features/favorites/domain/usecases/get_favorites_stream.dart';
import 'package:local_happens/features/favorites/domain/usecases/is_favorite.dart';
import 'package:local_happens/features/favorites/domain/usecases/remove_favorite.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesStream getFavoritesStreamUseCase;
  final AddFavorite addFavoriteUseCase;
  final RemoveFavorite removeFavoriteUseCase;
  final IsFavorite isFavoriteUseCase;
  final GetUsersByIds getUsersByIdsUseCase;
  final GetCitiesByIds getCitiesByIdsUseCase;

  StreamSubscription<List<Event>>? _subscription;

  FavoritesCubit({
    required this.getFavoritesStreamUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.isFavoriteUseCase,
    required this.getUsersByIdsUseCase,
    required this.getCitiesByIdsUseCase,
  }) : super(const FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(const FavoritesLoading());
    _subscription?.cancel();
    _subscription = getFavoritesStreamUseCase().listen((favorites) async {
      if (favorites.isEmpty) {
        emit(
          const FavoritesLoaded(
            favorites: [],
            favoriteIds: {},
          ),
        );
        return;
      }

      try {
        final citiesIds = favorites.map((event) => event.cityId).toSet();
        final usersIds = favorites.map((event) => event.userId).toSet();

        final cities = await getCitiesByIdsUseCase(citiesIds);
        final users = await getUsersByIdsUseCase(usersIds);
        
        final eventsUiModel = favorites.map((event) {
          final cityName = cities.firstWhere((city) => city.id == event.cityId).name;
          final userName = users.firstWhere((user) => user.id == event.userId).name;
          return EventUiModel.fromEvent(event, cityName, userName);
        }).toList();

        final favoriteIds = favorites.map((e) => e.id).toSet();
        emit(FavoritesLoaded(favorites: eventsUiModel, favoriteIds: favoriteIds));
      } catch (e) {
        emit(FavoritesError(e.toString()));
      }
    }, onError: (error) {
       emit(FavoritesError(error.toString()));
    });
  }

  Future<void> addFavoriteEvent(String eventId) async {
    try {
      // Optimitic update
      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;
        final newIds = Set<String>.from(currentState.favoriteIds)..add(eventId);
        emit(FavoritesLoaded(favorites: currentState.favorites, favoriteIds: newIds));
      }

      await addFavoriteUseCase(AddFavoriteParams(eventId: eventId));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> removeFavoriteEvent(String eventId) async {
    try {
      // Optimitic update
      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;
        final newIds = Set<String>.from(currentState.favoriteIds)..remove(eventId);
        emit(FavoritesLoaded(favorites: currentState.favorites, favoriteIds: newIds));
      }

      await removeFavoriteUseCase(RemoveFavoriteParams(eventId: eventId));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> toggleFavorite(String eventId) async {
    bool isFavorite = false;
    if (state is FavoritesLoaded) {
      isFavorite = (state as FavoritesLoaded).favoriteIds.contains(eventId);
    } else {
      isFavorite = await isFavoriteUseCase(IsFavoriteParams(eventId: eventId));
    }

    if (isFavorite) {
      await removeFavoriteEvent(eventId);
    } else {
      await addFavoriteEvent(eventId);
    }
  }

  Future<bool> checkIsFavorite(String eventId) async {
    if (_subscription == null) {
      loadFavorites();
    }

    if (state is FavoritesLoaded) {
       if ((state as FavoritesLoaded).favoriteIds.contains(eventId)) return true;
    }

    try {
      final isFavorite = await isFavoriteUseCase(
        IsFavoriteParams(eventId: eventId),
      );

      if (!isClosed && isFavorite && state is FavoritesLoaded) {
        final updatedIds = Set<String>.from((state as FavoritesLoaded).favoriteIds)..add(eventId);
        emit(
          FavoritesLoaded(favorites: (state as FavoritesLoaded).favorites, favoriteIds: updatedIds),
        );
      } else if (!isClosed && isFavorite) {
        // If not loaded yet, emit a temporary state to visually update immediately
        if (state is! FavoritesLoaded) {
          emit(FavoritesLoaded(favorites: const [], favoriteIds: {eventId}));
        }
      }

      return isFavorite;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
