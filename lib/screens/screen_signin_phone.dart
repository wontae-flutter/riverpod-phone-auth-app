import 'package:firebase_phone_auth_app/notifiers/notifier_signin_verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_global.dart';
import '../models/model_sign_in_state/sign_in_state.dart';

//* signIn도 똑같이 뭐가 있어야죠?
final signInPhoneModelProvider = StateNotifierProvider.autoDispose<SignInVerificationNotifier, SignInState>((ref) {
  return 
});

class SignInVerificationScreen extends ConsumerWidget {
  const SignInVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
