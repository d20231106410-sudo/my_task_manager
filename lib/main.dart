import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/login.dart';
import 'screens/task_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyTaskManagerApp());
}

class MyTaskManagerApp extends StatelessWidget {
  const MyTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 36),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: AppTheme.primary),
                ],
              ),
            ),
          );
        }

      if (snapshot.hasData && snapshot.data != null) {
        return const TaskListScreen();
      }

return const LoginScreen();
      },
    );
  }
}
