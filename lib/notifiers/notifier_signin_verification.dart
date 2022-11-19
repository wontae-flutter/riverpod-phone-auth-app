import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/service_auth.dart';
import '../models/model_sign_in_state/sign_in_state.dart';

final delayBeforeUserCanRequestNewCode = 30;

class SignInVerificationNotifier extends StateNotifier<SignInState> {
  SignInVerificationNotifier({
    required this.authService,
  }) : super(SignInState.notValid()) {
    _startTimer();
  }

  AuthService authService;
  String get formattedPhoneNumber => authService.formattedPhoneNumber;
  StreamController<int> countdown = StreamController<int>();

  //! 솔직히 얘들은 지역변수로 해도 되는거 아니냐?
  //! 글로벌로 하면 디스포즈 안해도 되는거 아니냐?

  void _startTimer() {
    int _countdown = delayBeforeUserCanRequestNewCode;
    var _timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        _countdown--;
        countdown.add(_countdown);
      }
    });
  }

  void resendCode() {
    state = SignInState.loading();
    try {
      authService.verifyPhone(() {
        state = SignInState.canSubmit();
        _startTimer();
      });
    } catch (e) {
      state = SignInState.error(e.toString());
    }
  }

  Future<void> verifyCode(String smsCode) async {
    state = SignInState.loading();
    try {
      await authService.verifyCode(smsCode, () {
        state = SignInState.success();
      });
    } catch (e) {
      state = SignInState.error(e.toString());
    }
  }
}
