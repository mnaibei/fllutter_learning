import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_learning/constants/routes.dart';
import 'package:flutter_learning/dialogs/show_error.dart';
import 'package:flutter_learning/views/register_view.dart';
import '../firebase_options.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
          title: const Text('Login'),
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
                            try {
                              final userCredential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: _email.text,
                                password: _password.text,
                              );
                              final user = userCredential.user!;
                              devtools.log('User signed in: $user');
                              return Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                      homeRoute, (route) => false)
                                  .then((_) {});
                            } on FirebaseAuthException catch (e) {
                              print(e.code);
                              if (e.code == "INVALID_LOGIN_CREDENTIALS") {
                                showErrorDialog(context, "Invalid Credentials");
                              } else {
                                showErrorDialog(context, e.code);
                              }
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            Future.delayed(Duration.zero, () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const Registerview(),
                              ));
                            });
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