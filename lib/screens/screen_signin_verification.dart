import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../providers/provider_global.dart';
import '../models/model_sign_in_state/sign_in_state.dart';
import '../notifiers/notifier_signin_verification.dart';
import '../styles.dart';

//* signIn도 똑같이 뭐가 있어야죠?
final signInVerificationNotifierProvider =
    StateNotifierProvider.autoDispose<SignInVerificationNotifier, SignInState>(
        (ref) {
  final authService = ref.watch(authServiceProvider);
  return SignInVerificationNotifier(
    authService: authService,
  );
});

final countdownProvider = StreamProvider.autoDispose<int>((ref) {
  final signInVerificationNotifier =
      ref.watch(signInVerificationNotifierProvider.notifier);
  return signInVerificationNotifier.countdown.stream;
});

class SignInVerificationScreenBuilder extends ConsumerWidget {
  const SignInVerificationScreenBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SignInState>(signInVerificationNotifierProvider,
        (previousState, nextState) {
      if (nextState == SignInState.success()) {
        Navigator.popUntil(context, ModalRoute.withName("/home"));
      }
    });

    final signInVerificationState =
        ref.watch(signInVerificationNotifierProvider);
    final countdown = ref.watch(countdownProvider);
    final signInVerificationNotifier =
        ref.watch(signInVerificationNotifierProvider.notifier);

    return SignInVerificationScreen(
      phoneNumber: signInVerificationNotifier.formattedPhoneNumber,
      delayBeforeNewCode: (countdown.value ?? delayBeforeUserCanRequestNewCode),
      resendCode: () => signInVerificationNotifier.resendCode(),
      verifyCode: (String smsCode) =>
          signInVerificationNotifier.verifyCode(smsCode),
      //* Freezed 기능, 모델을 쓸 때 모든 factory가 필요하며 none-null callback이어야 한다.
      //* 몇개만 쓰고 싶다면 maybeWhen
      canSubmit: signInVerificationState.maybeWhen(
          canSubmit: () => true, orElse: () => false),
      isLoading: signInVerificationState.maybeWhen(
          loading: () => true, orElse: () => false),
      errorText: signInVerificationState.maybeWhen(
          error: (error) => error, orElse: () => ""),
    );
  }
}

class SignInVerificationScreen extends StatefulWidget {
  const SignInVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.canSubmit = false,
    this.isLoading = false,
    required this.errorText,
    required this.delayBeforeNewCode,
    required this.resendCode,
    required this.verifyCode,
  });

  final String phoneNumber;
  final bool canSubmit;
  final bool isLoading;
  final int delayBeforeNewCode;
  final String errorText;
  final Function() resendCode;
  final Function(String smsCode) verifyCode;

  @override
  State<SignInVerificationScreen> createState() =>
      _SignInVerificationScreenState();
}

class _SignInVerificationScreenState extends State<SignInVerificationScreen> {
  //* 훅은 안써버릇 해야지...
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      textStyle: TextStyle(fontSize: 40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.blue),
      borderRadius: BorderRadius.circular(5),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Verification code",
        ),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: AppStyles.mainContainerPadding,
          child: Column(
            children: [
              Text(
                "Please enter the verfication code we sent to ${widget.phoneNumber}:",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(30.0),
                child: Pinput(
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  length: 6,
                  onTap: () {
                    if (widget.errorText != null) {
                      controller.text = "";
                    }
                  },
                  onSubmitted: widget.verifyCode,
                  focusNode: focusNode,
                  controller: controller,
                  pinAnimationType: PinAnimationType.none,
                  pinputAutovalidateMode: PinputAutovalidateMode.disabled,
                  validator: (number) {
                    if (widget.errorText == null && number!.length == 6) {
                      widget.verifyCode(number);
                    }
                    return null;
                  },
                ),
              ),
              TextButton(
                onPressed:
                    widget.delayBeforeNewCode > 0 ? null : widget.resendCode,
                child: Text(
                  widget.delayBeforeNewCode > 0
                      ? "If you did not receive the SMS, you will be able to request a new one in ${widget.delayBeforeNewCode.toString()} seconds"
                      : "Resend to ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.errorText != null) Text(widget.errorText),
            ],
          ),
        ),
      ),
    );
  }
}
