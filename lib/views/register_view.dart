// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_learning/constants/routes.dart';
import 'package:flutter_learning/dialogs/show_error.dart';
import 'package:flutter_learning/dialogs/show_success.dart';
import 'package:flutter_learning/services/auth/auth_exceptions.dart';
import 'package:flutter_learning/services/auth/auth_service.dart';
import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

class Registerview extends StatefulWidget {
  const Registerview({super.key});

  @override
  State<Registerview> createState() => _RegisterviewState();
}

class _RegisterviewState extends State<Registerview> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: FutureBuilder(
            future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return Column(
                    children: [
                      TextField(
                        controller: _email,
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            try {
                              await AuthService.firebase()
                                  .createUser(email: email, password: password);
                              final user = AuthService.firebase().currentUser;
                              await AuthService.firebase()
                                  .sendEmailVerification();
                              // ScaffoldMessenger.of(context)
                              //     .showSnackBar(SnackBar(
                              //   content: Text(
                              //       'Verification email sent to ${user!.email}'),
                              //   duration: const Duration(seconds: 3),
                              // ));
                              await showSuccessDialog(context,
                                  'Verification email sent to ${user!.email}');
                              return Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                      verifyEmailRoute, (route) => false)
                                  .then((_) {});
                            } on InvalidEmail {
                              await showErrorDialog(context, 'Invalid Email');
                            } on WeakPassword {
                              await showErrorDialog(context, 'Weak Password');
                            } on EmailAlreadyInUse {
                              await showErrorDialog(
                                  context, 'Email Already in Use');
                            }
                          },
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  );
                default:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
              }
            }));
  }
}
