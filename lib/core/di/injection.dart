import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

import '../services/storage_service.dart';
import '../services/network_service.dart';
import '../services/websocket_service.dart';
import '../services/connectivity_service.dart';
import '../../features/connection/data/repositories/connection_repository_impl.dart';
import '../../features/connection/domain/repositories/connection_repository.dart';
import '../../features/connection/domain/usecases/connect_to_server.dart';
import '../../features/connection/domain/usecases/disconnect_from_server.dart';
import '../../features/connection/domain/usecases/send_mouse_command.dart';
import '../../features/connection/presentation/bloc/connection_bloc.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/save_settings.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<Logger>(() => Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  ));
  
  // Core services
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<SharedPreferences>()),
  );
  
  getIt.registerLazySingleton<NetworkService>(
    () => NetworkService(getIt<Dio>()),
  );
  
  getIt.registerLazySingleton<WebSocketService>(
    () => WebSocketService(getIt<Logger>()),
  );
  
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(getIt<Connectivity>()),
  );
  
  // Repositories
  getIt.registerLazySingleton<ConnectionRepository>(
    () => ConnectionRepositoryImpl(
      webSocketService: getIt<WebSocketService>(),
      storageService: getIt<StorageService>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );
  
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      storageService: getIt<StorageService>(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton<ConnectToServer>(
    () => ConnectToServer(getIt<ConnectionRepository>()),
  );
  
  getIt.registerLazySingleton<DisconnectFromServer>(
    () => DisconnectFromServer(getIt<ConnectionRepository>()),
  );
  
  getIt.registerLazySingleton<SendMouseCommand>(
    () => SendMouseCommand(getIt<ConnectionRepository>()),
  );
  
  getIt.registerLazySingleton<GetSettings>(
    () => GetSettings(getIt<SettingsRepository>()),
  );
  
  getIt.registerLazySingleton<SaveSettings>(
    () => SaveSettings(getIt<SettingsRepository>()),
  );
  
  // BLoCs
  getIt.registerFactory<ConnectionBloc>(
    () => ConnectionBloc(
      connectToServer: getIt<ConnectToServer>(),
      disconnectFromServer: getIt<DisconnectFromServer>(),
      sendMouseCommand: getIt<SendMouseCommand>(),
    ),
  );
  
  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      getSettings: getIt<GetSettings>(),
      saveSettings: getIt<SaveSettings>(),
    ),
  );
}