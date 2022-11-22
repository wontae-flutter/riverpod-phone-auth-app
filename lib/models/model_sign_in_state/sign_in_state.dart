import 'package:freezed_annotation/freezed_annotation.dart';

part "sign_in_state.freezed.dart";

@freezed
class SignInState with _$SignInState {
  //* factory는 각각 정의가 완료되었는데...
  const factory SignInState.notValid() = _NotValid;
  const factory SignInState.canSubmit() = _CanSubmit;
  const factory SignInState.loading() = _Loading;
  const factory SignInState.success() = _Success;
  const factory SignInState.error(String errorText) = _Error;
}
