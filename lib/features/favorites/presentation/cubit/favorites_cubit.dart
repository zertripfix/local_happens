import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_happens/core/usecases/usecase.dart';
import 'package:local_happens/features/events/domain/entities/event.dart';
import 'package:local_happens/features/favorites/domain/usecases/add_favorite.dart';
import 'package:local_happens/features/favorites/domain/usecases/get_favorites.dart';
import 'package:local_happens/features/favorites/domain/usecases/is_favorite.dart';
import 'package:local_happens/features/favorites/domain/usecases/remove_favorite.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavorites getFavoritesUseCase;
  final AddFavorite addFavoriteUseCase;
  final RemoveFavorite removeFavoriteUseCase;
  final IsFavorite isFavoriteUseCase;

  FavoritesCubit({
    required this.getFavoritesUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.isFavoriteUseCase,
  }) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final favorites = await getFavoritesUseCase(NoParams());

      emit(
        FavoritesLoaded(
          favorites: List<Event>.from(favorites),
          favoriteIds: favorites.map((e) => e.id).toSet(),
        ),
      );
    } catch (e) {
      emit(
        FavoritesError(
          e.toString(),
          favorites: state.favorites,
          favoriteIds: state.favoriteIds,
        ),
      );
    }
  }

  Future<void> addFavoriteEvent(String eventId) async {
    final currentState = state as FavoritesLoaded;

    try {
      final updatedIds = Set<String>.from(currentState.favoriteIds)
        ..add(eventId);

      // локальне оновлення UI миттєво
      emit(
        FavoritesLoaded(
          favorites: currentState.favorites,
          favoriteIds: updatedIds,
        ),
      );

      // запит на сервер
      await addFavoriteUseCase(AddFavoriteParams(eventId: eventId));

      // оновлення всього списку у фоні
      final favorites = await getFavoritesUseCase(NoParams());
      emit(
        FavoritesLoaded(
          favorites: favorites,
          favoriteIds: favorites.map((e) => e.id).toSet(),
        ),
      );
    } catch (e) {
      emit(
        FavoritesError(
          e.toString(),
          favorites: currentState.favorites,
          favoriteIds: currentState.favoriteIds,
        ),
      );
    }
  }

  Future<void> removeFavoriteEvent(String eventId) async {
    if (state is! FavoritesLoaded) return;

    final currentState = state as FavoritesLoaded;

    try {
      // локальне видалення
      final updatedFavorites = currentState.favorites
          .where((e) => e.id != eventId)
          .toList();

      final updatedIds = Set<String>.from(currentState.favoriteIds)
        ..remove(eventId);

      emit(
        FavoritesLoaded(favorites: updatedFavorites, favoriteIds: updatedIds),
      );

      // видалення на сервері
      await removeFavoriteUseCase(RemoveFavoriteParams(eventId: eventId));
    } catch (e) {
      emit(
        FavoritesError(
          e.toString(),
          favorites: state.favorites,
          favoriteIds: state.favoriteIds,
        ),
      );
    }
  }

  Future<void> toggleFavorite(String eventId) async {
    if (state is! FavoritesLoaded) {
      await loadFavorites();
    }

    if (state is! FavoritesLoaded) return;

    final currentState = state as FavoritesLoaded;

    final isFavorite = currentState.favoriteIds.contains(eventId);

    if (isFavorite) {
      await removeFavoriteEvent(eventId);
      return;
    }

    await addFavoriteEvent(eventId);
  }

  Future<bool> checkIsFavorite(String eventId) async {
    if (state.favoriteIds.contains(eventId)) return true;

    try {
      final isFavorite = await isFavoriteUseCase(
        IsFavoriteParams(eventId: eventId),
      );

      if (!isClosed && isFavorite) {
        final updatedIds = Set<String>.from(state.favoriteIds)..add(eventId);
        emit(
          FavoritesLoaded(favorites: state.favorites, favoriteIds: updatedIds),
        );
      }

      return isFavorite;
    } catch (_) {
      return false;
    }
  }
}
