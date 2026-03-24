import 'package:local_happens/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:local_happens/features/events/domain/entities/event.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoritesRemoteDatasource remoteDatasource;

  FavoriteRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<List<Event>> getFavoritesStream() {
    return remoteDatasource.getFavoritesStream();
  }

  @override
  Future<bool> isFavorite(String eventId) {
    return remoteDatasource.isFavorite(eventId);
  }

  @override
  Future<void> addFavorite(String eventId) {
    return remoteDatasource.addFavorite(eventId);
  }

  @override
  Future<void> removeFavorite(String eventId) {
    return remoteDatasource.removeFavorite(eventId);
  }
}
