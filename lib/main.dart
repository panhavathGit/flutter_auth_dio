import 'package:auth_dio/core/Theme/app_theme.dart';
import 'package:auth_dio/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/services/storage_service.dart';
import 'core/network/dio_client.dart';

// auth
import './features/auth/auth.dart';
// todo
import './features/todo/todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final storageService = StorageService();
  final dioClient = DioClient(storageService);

  // ─── Switch between mock and real datasource ───
  final authDatasource = AppConfig.useMock
      ? AuthMockDatasource()
      : AuthRemoteDatasource(dioClient);

  final todoDatasource = AppConfig.useMock
      ? TodoMockDatasource()
      : TodoRemoteDatasource(dioClient);
  // ───────────────────────────────────────────────

  final authRepository = AuthRepository(authDatasource, storageService);
  final todoRepository = TodoRepositoryImpl(todoDatasource);

  final appRouter = AppRouter(storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TodoViewModel(todoRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: appTTheme,
        routerConfig: appRouter.router,
      ),
    ),
  );
}

//**  How to use mock login
//
//  When `useMock = true`, use these credentials on the login screen:
//
//  Email:  anything@example.com
//  Password:  123456    
//
// */ 
