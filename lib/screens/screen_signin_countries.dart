import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:flutter_libphonenumber/flutter_libphonenumber.dart";

import '../providers/provider_global.dart';

class SignInCountriesScreen extends StatelessWidget {
  const SignInCountriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Country / Region"),
      ),
      body: Consumer(
        builder: (context, ref, unrelatedChild) {
          final authService = ref.read(authServiceProvider);
          return ListView.separated(
            itemBuilder: (context, index) {
              final country = authService.countries[index];
              return ListTile(
                title: Text(
                  '${country.countryName}',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
                trailing: Text(
                  '+${country.phoneCode}',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
                onTap: () {
                  final authService = ref.read(authServiceProvider);
                  authService.setCountry(country);
                  Navigator.pop(context);
                },
              );
            },
            separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(left: 15),
              child: Divider(
                color: Colors.grey[400]!,
                height: 0.5,
              ),
            ),
            itemCount: authService.countries.length,
          );
        },
      ),
    );
  }
}
