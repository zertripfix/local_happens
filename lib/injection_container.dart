import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_happens/features/admin/domain/usecases/change_event_status.dart';
import 'package:local_happens/features/admin/domain/usecases/get_events_by_status.dart';
import 'package:local_happens/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:local_happens/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:local_happens/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:local_happens/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_happens/features/auth/domain/usecases/auth_state_changes.dart';
import 'package:local_happens/features/auth/domain/usecases/login_user.dart';
import 'package:local_happens/features/auth/domain/usecases/register_user.dart';
import 'package:local_happens/features/auth/domain/usecases/sign_in_with_google_user.dart';
import 'package:local_happens/features/auth/domain/usecases/sign_out_user.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:local_happens/features/events/data/datasources/cities_remote_datasource.dart';
import 'package:local_happens/features/events/data/datasources/event_remote_datasource.dart';
import 'package:local_happens/features/events/data/datasources/users_remote_datasource.dart';
import 'package:local_happens/features/events/data/repositories/cities_repository_impl.dart';
import 'package:local_happens/features/events/data/repositories/event_repository_impl.dart';
import 'package:local_happens/features/events/data/repositories/geocoding_repository_impl.dart';
import 'package:local_happens/features/events/data/repositories/users_repository_impl.dart';
import 'package:local_happens/features/events/domain/repositories/cities_repository.dart';
import 'package:local_happens/features/events/domain/repositories/event_repository.dart';
import 'package:local_happens/features/events/domain/repositories/geocoding_repository.dart';
import 'package:local_happens/features/events/domain/repositories/users_repository.dart';
import 'package:local_happens/features/events/domain/usecases/create_event.dart';
import 'package:local_happens/features/events/domain/usecases/delete_event.dart';
import 'package:local_happens/features/events/domain/usecases/filter_events.dart';
import 'package:local_happens/features/events/domain/usecases/get_cities_by_ids.dart';
import 'package:local_happens/features/events/domain/usecases/get_event_by_id.dart';
import 'package:local_happens/features/events/domain/usecases/get_events_stream.dart';
import 'package:local_happens/features/events/domain/usecases/get_or_create_city.dart';
import 'package:local_happens/features/events/domain/usecases/get_user_events_stream.dart';
import 'package:local_happens/features/events/domain/usecases/get_users_by_ids.dart';
import 'package:local_happens/features/events/domain/usecases/resolve_location_from_coordinates.dart';
import 'package:local_happens/features/events/domain/usecases/update_event.dart';
import 'package:local_happens/features/events/domain/usecases/upload_event_image.dart';
import 'package:local_happens/features/events/domain/usecases/add_user_to_attendees.dart';
import 'package:local_happens/features/events/domain/usecases/remove_user_from_attendees.dart';
import 'package:local_happens/features/events/presentation/cubit/create_event_cubit.dart';
import 'package:local_happens/features/events/presentation/cubit/event_details_cubit.dart';
import 'package:local_happens/features/events/presentation/cubit/events_cubit.dart';
import 'package:local_happens/features/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:local_happens/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:local_happens/features/favorites/domain/usecases/add_favorite.dart';
import 'package:local_happens/features/favorites/domain/usecases/get_favorites.dart';
import 'package:local_happens/features/favorites/domain/usecases/is_favorite.dart';
import 'package:local_happens/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:local_happens/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:local_happens/features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);

  // Features - Auth
  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUser: sl(),
      registerUser: sl(),
      signInWithGoogleUser: sl(),
      signOutUser: sl(),
      authStateChanges: sl(),
    ),
  );

  // DataSource
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      firestore: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUser(sl()));
  sl.registerLazySingleton(() => SignOutUser(sl()));
  sl.registerLazySingleton(() => AuthStateChanges(sl()));

  // Features - Admin
  sl.registerFactory(
    () => AdminCubit(
      getEventsByStatus: sl(),
      changeEventStatusUseCase: sl(),
      getUsersByIdsUseCase: sl(),
      getCitiesByIdsUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetEventsByStatus(sl()));
  sl.registerLazySingleton(() => ChangeEventStatus(sl()));

  // Features - Events
  // Cubits
  sl.registerFactory(
    () => EventsCubit(
      getEvents: sl(),
      getCitiesByIdsUseCase: sl(),
      getUsersByIdsUseCase: sl(),
      createEventUseCase: sl(),
      updateEventUseCase: sl(),
      deleteEventUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => EventDetailsCubit(
      getEventByIdUseCase: sl(),
      getUsersByIdsUseCase: sl(),
      getCitiesByIdsUseCase: sl(),
      addUserToAttendeesUseCase: sl(),
      removeUserFromAttendeesUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CreateEventCubit(
      resolveLocation: sl(),
      getOrCreateCity: sl(),
      createEventUseCase: sl(),
      uploadEventImage: sl(),
    ),
  );

  // DataSources
  sl.registerLazySingleton<EventRemoteDatasource>(
    () => EventRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<CitiesRemoteDatasource>(
    () => CitiesRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<UsersRemoteDatasource>(
    () => UsersRemoteDatasourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(remoteDatasource: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<CitiesRepository>(
    () => CitiesRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<GeocodingRepository>(
    () => GeocodingRepositoryImpl(),
  );
  sl.registerLazySingleton<UsersRepository>(() => UsersRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetEventsStream(sl()));
  sl.registerLazySingleton(() => CreateEvent(sl()));
  sl.registerLazySingleton(() => UpdateEvent(sl()));
  sl.registerLazySingleton(() => DeleteEvent(sl()));
  sl.registerLazySingleton(() => FilterEvents(sl()));
  sl.registerLazySingleton(() => GetEventById(sl()));
  sl.registerLazySingleton(() => GetUserEventsStream(sl()));
  sl.registerLazySingleton(() => GetCitiesByIds(sl()));
  sl.registerLazySingleton(() => GetUsersByIds(sl()));
  sl.registerLazySingleton(() => ResolveLocationFromCoordinates(sl()));
  sl.registerLazySingleton(() => GetOrCreateCity(sl()));
  sl.registerLazySingleton(() => UploadEventImage(sl()));
  sl.registerLazySingleton(() => AddUserToAttendeesUseCase(sl()));
  sl.registerLazySingleton(() => RemoveUserFromAttendeesUseCase(sl()));

  // Features - Favorites
  sl.registerFactory(
    () => FavoritesCubit(
      getFavoritesUseCase: sl(),
      addFavoriteUseCase: sl(),
      removeFavoriteUseCase: sl(),
      isFavoriteUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetFavorites(sl()));
  sl.registerLazySingleton(() => AddFavorite(sl()));
  sl.registerLazySingleton(() => RemoveFavorite(sl()));
  sl.registerLazySingleton(() => IsFavorite(sl()));
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(firestore: sl(), firebaseAuth: sl()),
  );

  // Features - Profile
  sl.registerFactory(() => ProfileCubit(sl()));
}
