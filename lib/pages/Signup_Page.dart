import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/models/User.dart';
import 'package:todo/pages/Home_Page.dart';
import 'Login_Page.dart';

class Signup_Page extends StatefulWidget {
  const Signup_Page({Key? key}) : super(key: key);

  @override
  State<Signup_Page> createState() => _Signup_PageState();
}

class _Signup_PageState extends State<Signup_Page> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void createAccount() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == "" || password == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all the details!")));
    } else if (password != cPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords donot match!")));
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ex.code.toString())));
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      UserModel newUser = UserModel(email: email, uid: uid);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("new user created!");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Home_Page(
            currentUser: newUser,
            firebaseUser: credential!.user!,
          );
        }));
      });
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
              "Sign Up",
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
                decoration: const InputDecoration(hintText: "Password"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11.0),
              child: TextField(
                controller: cPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Confirm Password"),
              ),
            ),
            InkWell(
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Login_Page();
                  }));
                },
                child: const Text("Already have an account?")),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () {
                  createAccount();
                },
                child: const Text("     Signup    ",
                    style: TextStyle(fontSize: 21))),
          ],
        ),
      ),
    );
  }
}
