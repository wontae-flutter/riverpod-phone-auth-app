import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/CustomElevatedButton.dart';
import '../providers/provider_global.dart';
import '../styles.dart';

class SignInScreen extends ConsumerWidget {
  Future<void> _openSignUp(BuildContext context) async {
    final navigator = Navigator.of(context);
    await navigator.pushNamed(
      "/sign-in-phone",
      arguments: () => navigator.pop(),
    );
    //! 와... 이거 pushReplacementNamed랑 같은게 아닌가요?
  }

  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //! 이거 왜 못쓰지?
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Firebase Phone Auth with Riverpod",
        ),
      ),
      body: Center(
        child: Container(
          padding: AppStyles.mainContainerPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(size: 120),
              SizedBox(height: 15),
              CustomElevatedButton(
                title: "Sign in with phone number",
                onPressed: () => _openSignUp(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//! 홈피 잘못했음
// Container(
//           padding: AppStyles.mainContainerPadding,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(50.0),
//                   ),
//                 ),
//                 child: Icon(
//                   Icons.check,
//                   color: Colors.white,
//                   size: 80,
//                 ),
//               ),

// RichText(
//                 text: TextSpan(
//                     text: "You have successfully signed in with phone number",
//                     style: Theme.of(context).textTheme.headline6,
//                     children: [
//                       TextSpan(
//                         text: "1",
//                         // text: phoneNumber,
//                         style: Theme.of(context).textTheme.headline4,
//                       )
//                     ]),
//                 textAlign: TextAlign.center,
//               ),