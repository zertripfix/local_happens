import 'package:local_happens/features/events/domain/entities/event.dart';
import 'package:local_happens/features/favorites/domain/repositories/favorite_repository.dart';

class GetFavoritesStream {
  final FavoriteRepository repository;

  GetFavoritesStream(this.repository);

  Stream<List<Event>> call() {
    return repository.getFavoritesStream();
  }
}
