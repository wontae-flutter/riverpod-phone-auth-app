import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

import '../models/model_auth_state/auth_state.dart';

//! 제발 돼라...
class AuthService extends StateNotifier<AuthState> {
  AuthService({
    // this.kselectedCountry,
    this.kphoneNumber,
    this.kverificationId,
  }) : super(AuthState.initializing()) {
    _firebaseAuth = FirebaseAuth.instance;
    //* Instantiation되면서 FlutterLibphonenumber().init() 실행됨
    _loadCountries();
  }

  //todo 기본값만 주면 해결되는...
  late FirebaseAuth _firebaseAuth;
  CountryWithPhoneCode kselectedCountry = CountryWithPhoneCode.us();
  Map? kphoneNumber;
  String? kverificationId;
  List<CountryWithPhoneCode> countries = [];

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();
  CountryWithPhoneCode? get selectedCountry => kselectedCountry;
  String get phoneCode => kselectedCountry.phoneCode;
  String get formattedPhoneNumber => kphoneNumber!['international'];

  Future<void> _loadCountries() async {
    try {
      //* init 들어가 있음
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
    kphoneNumber = await FlutterLibphonenumber().parse(
      "+${kselectedCountry.phoneCode}${inputText.replaceAll(RegExp(r'[^0-9]'), '')}",
      region: selectedCountry!.countryCode,
    );
    if (kphoneNumber!['type'] != 'mobile') {
      throw Exception('You must enter a mobile phone number.');
    }
  }

  //todo completion()은 단순히 콜백을 말하는 것 같고...
  //! 여기서 내가 Null value에 !를 붙였대.
  Future<void> verifyPhone(Function() completion) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: kphoneNumber!['e164'],
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
      verificationId: kverificationId!,
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
