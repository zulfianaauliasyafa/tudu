import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/core/di/injection_container.dart' as di;
import 'package:taskly/presentation/bloc/auth_bloc.dart';
import 'package:taskly/presentation/bloc/task_bloc.dart';
import 'package:taskly/presentation/pages/addtask_page.dart';
import 'package:taskly/presentation/pages/home_page.dart';
import 'package:taskly/presentation/pages/login_page.dart';
import 'package:taskly/presentation/pages/regist_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBpWxcYCufGfvxYjsPY8JPQ3VyPkab1QV4",
          appId: "1:391644262607:web:6b42f9f9e752c9d36e87ba",
          messagingSenderId: "391644262607",
          projectId: "project-akhir-pam-4f1a1",
          databaseURL:
              "https://project-akhir-pam-4f1a1-default-rtdb.asia-southeast1.firebasedatabase.app",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    // Initialize dependency injection
    await di.init();

    runApp(const MainApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
    // You might want to show an error screen here
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent())),
        BlocProvider(create: (_) => di.sl<TaskBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthCheck(),
        routes: {
          '/regist': (context) => const RegistPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/add': (context) => AddTaskPage(),
        },
      ),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    // Tunggu widget selesai build sebelum mengecek status auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('AuthCheck state: $state');

        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is Authenticated) {
          print('User is authenticated, navigating to HomePage');
          return const HomePage();
        } else {
          print('User is not authenticated, navigating to LoginPage');
          return const LoginPage();
        }
      },
    );
  }
}
