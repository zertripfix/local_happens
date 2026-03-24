import 'package:local_happens/features/events/domain/entities/event.dart';

abstract class FavoriteRepository {
  Stream<List<Event>> getFavoritesStream();
  Future<bool> isFavorite(String eventId);
  Future<void> addFavorite(String eventId);
  Future<void> removeFavorite(String eventId);
}
