// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShapeShift',
      theme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        primaryColorBrightness: Brightness.dark,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) return Colors.grey;
              return null;
            }),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) return Colors.grey;
              return null;
            }),
          ),
        ),
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        primaryColorLight: Colors.red,
        primaryColorDark: Colors.red,
        accentColor: Colors.redAccent,
        shadowColor: Colors.red,
        bottomAppBarColor: Colors.red,
        cardColor: Colors.red,
        hoverColor: Colors.red,
        highlightColor: Colors.red,
        dialogBackgroundColor: Colors.red,
        indicatorColor: Colors.red,
        errorColor: Colors.red,
        toggleableActiveColor: Colors.red,
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: Colors.red,
          ),
          displayMedium: TextStyle(
            color: Colors.grey,
          ),
          displaySmall: TextStyle(
            color: Colors.red,
          ),
          headlineMedium: TextStyle(
            color: Colors.grey,
          ),
          headlineSmall: TextStyle(
            color: Colors.red,
          ),
          titleLarge: TextStyle(
            color: Colors.grey,
          ),
          bodySmall: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  Future<void> _checkLocationPermission(BuildContext context) async {
    _navigateToLogin(context);
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _checkLocationPermission(context),
              child: const Text('Log In'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToSignup(context),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Please enter your email.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Please enter your password.';
                }
                return null;
              },
            ),
            ElevatedButton(
              child: const Text('Sign In'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await _auth.signInWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HomePage(email: _emailController.text),
                      ),
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Something went wrong.'),
                          content: Text(e.toString()),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      },
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  late String _email, _password, _username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                validator: (input) {
                  if (input!.isEmpty) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (input) => _email = input!,
              ),
              TextFormField(
                validator: (input) {
                  if (input!.isEmpty) {
                    return 'Please enter a valid username';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Username'),
                onSaved: (input) => _username = input!,
              ),
              TextFormField(
                validator: (input) {
                  if (input!.length < 6) {
                    return 'Your password must be at least 6 characters';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (input) => _password = input!,
              ),
              ElevatedButton(
                onPressed: signUp,
                child: const Text('Sign Up'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        User? user = userCredential.user;
        if (user != null) {
          user.updateDisplayName(_username);
        }
        FirebaseFirestore.instance.collection('users').doc(user!.uid).set(
            {'username': _username, 'email': _email, 'password': _password});
        Navigator.pop(context); // Return to homepage after signing up
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  void _fetchUsername() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      setState(() {
        _username = userData['username'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page of: $_username'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              child: const Text('Log Out'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OtherPage()),
                );
              },
              child: const Text('Go to Other Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class OtherPage extends StatelessWidget {
  const OtherPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Page (under construction)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('This will be cool in a few weeks.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Home Page'),
            ),
          ],
        ),
      ),
    );
  }
}
