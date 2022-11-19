import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

import '../providers/provider_global.dart';
import '../models/model_sign_in_state/sign_in_state.dart';
import '../notifiers/notifier_signin_phone.dart';
import '../widgets/CustomElevatedButton.dart';
import '../styles.dart';

final signInPhoneNotifierProvider =
    StateNotifierProvider.autoDispose<SignInPhoneNotifier, SignInState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SignInPhoneNotifier(authService: authService);
});

final selectedCountryProvider =
    Provider.autoDispose<CountryWithPhoneCode?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
      ready: (selectedCountry) => selectedCountry, orElse: () => null);
});

class SignInPhoneScreenBuilder extends ConsumerWidget {
  const SignInPhoneScreenBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}

class SignInPhoneScreen extends StatefulWidget {
  SignInPhoneScreen({
    this.canSubmit = false,
    this.isLoading = false,
    required this.errorText,
    required this.phoneCode,
    required this.phonePlaceholder,
    required this.formatter,
    required this.onSubmit,
  });

  final LibPhonenumberTextFormatter formatter;
  final String phoneCode;
  final String phonePlaceholder;
  final bool canSubmit;
  final bool isLoading;
  final String errorText;
  final Function()? onSubmit;

  @override
  State<SignInPhoneScreen> createState() => _SignInPhoneScreenState();
}

class _SignInPhoneScreenState extends State<SignInPhoneScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Sign in with phone number",
        ),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: AppStyles.mainContainerPadding,
          child: Column(
            children: [
              Text(
                "Please enter your phone number to receive a verification code.",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/countries");
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        widget.phoneCode,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      focusNode: focusNode,
                      keyboardType: TextInputType.phone,
                      controller: controller,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: widget.phonePlaceholder,
                        hintStyle: TextStyle(
                          fontSize: 18,
                          letterSpacing: -0.2,
                          color: Colors.grey[400],
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[300]!, width: 1.0),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              CustomElevatedButton(
                title: "Continue",
                onPressed: widget.canSubmit ? widget.onSubmit : null,
              ),
              if (widget.errorText != null) Text(widget.errorText),
            ],
          ),
        ),
      ),
    );
  }
}
