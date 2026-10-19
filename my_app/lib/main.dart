import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'theme/app_theme.dart';
import 'services/account_registration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool connected = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    connected = true;
  } catch (_) {
    /* Preview stays usable until project configuration is supplied. */
  }
  runApp(GoodTogetherApp(connected: connected));
}

class GoodTogetherApp extends StatelessWidget {
  final bool connected;
  const GoodTogetherApp({super.key, this.connected = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Göod Together',
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      home: connected
          ? StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return ValueListenableBuilder<bool>(
                  valueListenable: AccountRegistration.inProgress,
                  builder: (context, registering, _) => HomeShell(
                    key: ValueKey(
                      registering ? 'guest' : snapshot.data?.uid ?? 'guest',
                    ),
                    connected: true,
                    signedIn: snapshot.data != null && !registering,
                  ),
                );
              },
            )
          : const HomeShell(),
    );
  }
}
