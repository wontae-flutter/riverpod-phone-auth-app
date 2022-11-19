import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

import '../models/model_auth_state/auth_state.dart';

//! 제발 돼라...
class AuthService extends StateNotifier<AuthState> {
  AuthService({
    this.selectedCountry,
    this.phoneNumber,
    this.verificationId,
  }) : super(AuthState.initializing()) {
    _firebaseAuth = FirebaseAuth.instance;
    _loadCountries();
  }

  late FirebaseAuth _firebaseAuth;
  CountryWithPhoneCode? selectedCountry;
  Map? phoneNumber;
  String? verificationId;
  List<CountryWithPhoneCode> countries = [];

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();
  CountryWithPhoneCode? get getSelectedCountry => selectedCountry;
  String get phoneCode => selectedCountry!.phoneCode;
  String get formattedPhoneNumber => phoneNumber!['international'];

  Future<void> _loadCountries() async {
    try {
      await FlutterLibphonenumber().init();
      var _countries = CountryManager().countries;
      _countries.sort((a, b) {
        return a.countryName!
            .toLowerCase()
            .compareTo(b.countryName!.toLowerCase());
      });
      countries = _countries;

      final langCode = ui.window.locale.languageCode.toUpperCase();
      _firebaseAuth.setLanguageCode(langCode);

      var filteredCountries =
          countries.where((item) => item.countryCode == langCode);

      if (filteredCountries.length == 0) {
        filteredCountries = countries.where((item) => item.countryCode == 'US');
      }
      if (filteredCountries.length == 0) {
        throw Exception('Unable to find a default country!');
      }
      setCountry(filteredCountries.first);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void setCountry(CountryWithPhoneCode selectedCountry) {
    selectedCountry = selectedCountry;
    state = AuthState.ready(selectedCountry);
  }

  Future<void> parsePhoneNumber(String inputText) async {
    phoneNumber = await FlutterLibphonenumber().parse(
      "+${selectedCountry!.phoneCode}${inputText.replaceAll(RegExp(r'[^0-9]'), '')}",
      region: selectedCountry!.countryCode,
    );
    if (phoneNumber!['type'] != 'mobile') {
      throw Exception('You must enter a mobile phone number.');
    }
  }

  //todo completion()은 단순히 콜백을 말하는 것 같고...
  Future<void> verifyPhone(Function() completion) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber!['e164'],
      verificationCompleted: (AuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseException e) {
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationId = verificationId;
        completion();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationId = verificationId;
        completion();
      },
      timeout: Duration(seconds: 120),
    );
  }

  Future<void> verifyCode(String smsCode, Function() completion) async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: smsCode,
    );
    final user = await _firebaseAuth.signInWithCredential(credential);
    if (user != null) {
      completion();
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
