import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/model_auth_state/auth_state.dart';
import '../services/service_auth.dart';

// //* = authRepository
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

//* 1st Param(Notifier)에 의해 변화되는 2nd Param을 리턴
final authStateProvider = StateNotifierProvider<AuthService, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authStateChange = ref.watch(authServiceProvider).authStateChanges();
  return authStateChange;
});
