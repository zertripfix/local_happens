import 'package:equatable/equatable.dart';
import 'package:local_happens/features/events/presentation/models/event_ui_model.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<EventUiModel> favorites;
  final Set<String> favoriteIds;

  const FavoritesLoaded({this.favorites = const [], this.favoriteIds = const {}});

  @override
  List<Object> get props => [favorites, favoriteIds];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}
