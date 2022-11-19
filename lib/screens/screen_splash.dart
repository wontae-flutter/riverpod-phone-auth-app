import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_global.dart';

import './screens.dart';

//* firebase랑 연결 안했는데?
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    return authStateChanges.when(
        data: (user) {
          if (user != null) {
            // return Text("hji");
            return HomeScreen();
          } else {
            // return Text("hdfsd");
            return SignInScreen();
          }
        },
        loading: () => Center(
              child: CircularProgressIndicator(),
            ),
        error: (error, _) => ErrorPage(message: error.toString()));
  }
}
