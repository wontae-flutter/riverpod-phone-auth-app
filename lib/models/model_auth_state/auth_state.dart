import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

part 'auth_state.freezed.dart';

//todo flutter_libphonenumber이게 뭐하는 놈인지는 나중에 보자!

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initializing() = _AuthStateInitializing;
  const factory AuthState.ready(CountryWithPhoneCode country) = _AuthStateReady;
  const factory AuthState.error(String errorText) = _AuthStateError;
}
