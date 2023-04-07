// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

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
        //primaryColorBrightness: Brightness.dark,
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
        //accentColor: Colors.redAccent,
        shadowColor: Colors.red,
        //bottomAppBarColor: Colors.red,
        cardColor: Colors.red,
        hoverColor: Colors.red,
        highlightColor: Colors.red,
        dialogBackgroundColor: Colors.red,
        indicatorColor: Colors.red,
        textTheme: const TextTheme(
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
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.red;
            }
            return null;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.red;
            }
            return null;
          }),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.red;
            }
            return null;
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.red;
            }
            return null;
          }),
        ),
      ),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

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

  void _navigateToResetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToLogin(context),
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToSignup(context),
              child: const Text('Sign up'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToResetPassword(context),
              child: const Text('Reset Password'),
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

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String errorMessage = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter your email address to reset your password',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Email is required';
                    } else if (!value.contains('@')) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String email = emailController.text;
                      try {
                        if (kDebugMode) {
                          print(
                              'Checking if $email is registered with Firebase...');
                        } // Debugging statement
                        List<String> signInMethods = await FirebaseAuth.instance
                            .fetchSignInMethodsForEmail(email);
                        if (signInMethods.isEmpty) {
                          if (kDebugMode) {
                            print('$email is not registered with Firebase.');
                          } // Debugging statement
                          errorMessage =
                              'This email is not registered with Firebase.';
                          emailController.clear();
                        } else {
                          if (kDebugMode) {
                            print('$email is registered with Firebase.');
                          } // Debugging statement
                          if (kDebugMode) {
                            print('Sending password reset email to $email...');
                          } // Debugging statement
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);
                          if (kDebugMode) {
                            print('Password reset email sent successfully.');
                          } // Debugging statement
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password reset email sent successfully.'),
                            ),
                          );
                          emailController.clear();
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error sending password reset email: $e');
                        } // Debugging statement
                        errorMessage = 'Error sending password reset email.';
                        emailController.clear();
                      }
                    }
                  },
                  child: const Text('Reset Password'),
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoutinesPage()),
                );
              },
              child: const Text('Go to Settings Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutsPage()),
                );
              },
              child: const Text('Go to Workouts Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              child: const Text('Go to Settings Page'),
            ),
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
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'User Profile',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(FirebaseAuth.instance.currentUser!.email ?? ''),
          ),
          ListTile(
            title: const Text('Username'),
            subtitle: const Text('John Doe'), // Replace with user's username
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Change Password',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Current Password'),
            subtitle: const TextField(),
          ),
          ListTile(
            title: const Text('New Password'),
            subtitle: const TextField(),
          ),
          ListTile(
            title: const Text('Confirm New Password'),
            subtitle: const TextField(),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Data Management',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Clear Data'),
            subtitle: const Text('Delete all workout routines'),
            trailing: const Icon(Icons.delete),
            onTap: () {
              // I should put something here
            },
          ),
          ListTile(
            title: const Text('Delete All Routines and Quit All Groups'),
            subtitle: const Text('Delete all routines and leave all groups'),
            trailing: const Icon(Icons.delete_forever),
            onTap: () {
              // we should implement delete all routines and quit all groups functionality
            },
          ),
          const SizedBox(height: 20),
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
        ],
      ),
    );
  }
}

class RoutinesPage extends StatelessWidget {
  const RoutinesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines Page (under construction)'),
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

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts Page (under construction)'),
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
