import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_state.dart';
import 'package:local_happens/features/events/domain/entities/event.dart';
import 'package:local_happens/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:local_happens/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:local_happens/features/events/presentation/widgets/event_card_widget.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<FavoritesCubit>();
    if (cubit.state is! FavoritesLoaded) {
      context.read<FavoritesCubit>().loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обране')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! Authenticated) {
            return _UnauthorizedFavoritesView(
              onLoginPressed: () => context.push('/login'),
            );
          }

          return BlocConsumer<FavoritesCubit, FavoritesState>(
            listener: (context, state) {
              if (state is FavoritesError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              final favorites = state is FavoritesLoaded
                  ? state.favorites
                  : <Event>[];
              final favoriteIds = state is FavoritesLoaded
                  ? state.favoriteIds
                  : <String>{};

              // Loading
              if (state is FavoritesLoading || state is FavoritesInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (favorites.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<FavoritesCubit>().loadFavorites(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 120),
                      _EmptyFavoritesView(),
                    ],
                  ),
                );
              }

              // Cards grid
              return RefreshIndicator(
                onRefresh: () => context.read<FavoritesCubit>().loadFavorites(),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final event = favorites[index];

                    return Stack(
                      children: [
                        Positioned.fill(child: EventCard(event: event)),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Material(
                            color: Colors.white.withOpacity(0.92),
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'Видалити з обраного',
                              icon: Icon(
                                favoriteIds.contains(event.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: favoriteIds.contains(event.id)
                                    ? Colors.redAccent
                                    : Colors.black87,
                              ),
                              onPressed: () => context
                                  .read<FavoritesCubit>()
                                  .removeFavoriteEvent(event.id),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _UnauthorizedFavoritesView extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const _UnauthorizedFavoritesView({required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Зберігайте улюблені події',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Ввійдіть, щоб зберігати цікаві події та мати до них швидкий доступ',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onLoginPressed,
            child: const Text('Увійти'),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  const _EmptyFavoritesView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.favorite_outline, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Поки що порожньо',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Збережіть події, щоб вони з`явились тут',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
