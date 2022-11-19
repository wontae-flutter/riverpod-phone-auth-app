import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_global.dart';

final phoneNumberProvider = Provider.autoDispose<String>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.formattedPhoneNumber;
});

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    );
  }
}
