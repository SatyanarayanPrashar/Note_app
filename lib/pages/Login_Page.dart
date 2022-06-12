import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/models/UIHelper.dart';
import 'package:todo/models/User.dart';
import 'package:todo/pages/Home_Page.dart';
import 'package:todo/pages/Signup_Page.dart';

class Login_Page extends StatefulWidget {
  const Login_Page({Key? key}) : super(key: key);

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkvalues() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == null || password == null) {
      const snackBar = SnackBar(content: Text("Please fill all the details!"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseException catch (ex) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ex.code.toString())));
    }

    UIHelper.showLoadingAlertDialog(context, "loading");

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Home_Page(
            currentUser: userModel, firebaseUser: credential!.user!);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 170),
            const Text(
              "Login",
              style: TextStyle(fontSize: 70),
            ),
            Padding(
              padding: const EdgeInsets.all(11.0),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: "Email"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(hintText: "Password"),
              ),
            ),
            InkWell(
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Signup_Page();
                  }));
                },
                child: const Text("New here?")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  checkvalues();
                },
                child: const Text("     Login    ",
                    style: TextStyle(fontSize: 21)))
          ],
        ),
      ),
    );
  }
}
