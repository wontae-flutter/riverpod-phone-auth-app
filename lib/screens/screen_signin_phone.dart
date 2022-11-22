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

  Future<void> _openVerification(BuildContext context) async {
    //? 여기서 들어가는거구나
    await Navigator.of(context).pushNamed("/sign-in-verification");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //! 지금 state가 바뀌지 않으니까 .... 요게 안 들어가는거야.
    ref.listen<SignInState>(signInPhoneNotifierProvider,
        (previousState, nextState) {
      if (nextState == SignInState.success()) {
        _openVerification(context);
      }
    });
    final signInPhoneState = ref.watch(signInPhoneNotifierProvider);
    final selectedCountry = ref.watch(selectedCountryProvider);
    final signInPhoneNotifier = ref.watch(signInPhoneNotifierProvider.notifier);

    print("signInPhoneState: $signInPhoneState");
    print("selectedCountry countryCode: ${selectedCountry!.countryCode}");
    print("selectedCountry countryName: ${selectedCountry.countryName}");

    //! When the phone number is detected as valid, the "Continue" button is enabled.
    //! HOW?
    return SignInPhoneScreen(
      phoneCode: '+${selectedCountry!.phoneCode}',
      phonePlaceholder: selectedCountry.exampleNumberMobileInternational
          .replaceAll('+${selectedCountry.phoneCode} ', ''),
      formatter: signInPhoneNotifier.phoneNumberFormatter,
      onSubmit: signInPhoneNotifier.verifyPhone,
      canSubmit: signInPhoneState.maybeWhen(
        notValid: () => false,
        canSubmit: () => true,
        success: () => true,
        //* 아무것도 해당이 되지 않을 때 default값으로,
        //? 즉 현재는 canSubmit도 아니고, suceess도 아니라는 것
        error: (errorText) {
          print(errorText);
          return false;
        },
        orElse: () => false,
      ),
      isLoading: signInPhoneState.maybeWhen(
        loading: () => true,
        orElse: () => false,
      ),
      errorText: signInPhoneState.maybeWhen(
        error: (error) => error,
        orElse: () => "",
      ),
    );
  }
}

class SignInPhoneScreen extends StatefulWidget {
  SignInPhoneScreen({
    this.isLoading = false,
    required this.canSubmit,
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
    controller.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _printLatestValue() {
    print("current phone number: ${controller.text}");
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
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Please enter your phone number to receive a verification code.",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
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
                      inputFormatters: [widget.formatter],
                      focusNode: focusNode,
                      keyboardType: TextInputType.phone,
                      controller: controller,
                      validator: (value) {
                        print(value);
                      },
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
              //todo 끝까지 안되어있네?
              //! controller.text값을 notifier.
              SizedBox(height: 30),
              CustomElevatedButton(
                title: "Continue",
                onPressed: widget.canSubmit ? widget.onSubmit : null,
                // onPressed: () {
                //   //* widget.canSubmit가 false가 나오는데...
                //   print(widget.canSubmit);
                //   print(widget.onSubmit);
                // },
              ),
              if (widget.errorText != null) Text(widget.errorText),
            ],
          ),
        ),
      ),
    );
  }
}


// canSubmit: signInPhoneState.maybeWhen(
//  canSubmit: () => true,
//  success: () => true,
//  orElse: () => false,
// ),
//* maybeWhenㅇ
//* 
//* 
//* 
//* 
//* 