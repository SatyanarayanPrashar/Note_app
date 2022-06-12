import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo/pages/Home_Page.dart';
import 'package:uuid/uuid.dart';
import 'models/FirebaseHelper.dart';
import 'models/User.dart';
import 'pages/Login_Page.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? activeUser = FirebaseAuth.instance.currentUser;

  if (activeUser != null) {
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(activeUser.uid);
    if (thisUserModel != null) {
      runApp(MyAppLoggedIn(
        currentUser: thisUserModel,
        firebaseUser: activeUser,
      ));
    } else
      runApp(MyApp());
  } else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Login_Page(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel currentUser;
  final User firebaseUser;
  const MyAppLoggedIn(
      {Key? key, required this.currentUser, required this.firebaseUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Home_Page(currentUser: currentUser, firebaseUser: firebaseUser),
    );
  }
}
