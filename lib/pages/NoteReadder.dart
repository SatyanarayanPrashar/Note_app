import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/models/NoteModel.dart';
import 'package:todo/models/UIHelper.dart';
import 'package:todo/models/User.dart';
import 'package:todo/pages/Home_Page.dart';

class NoteReader extends StatefulWidget {
  NoteReader(
    this.currentNote, {
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);
  final NoteModel currentNote;
  final UserModel userModel;
  final User firebaseUser;

  @override
  State<NoteReader> createState() => _NoteReaderState();
}

class _NoteReaderState extends State<NoteReader> {
  void deleteNote() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .collection("notes")
        .doc(widget.currentNote.noteid)
        .delete()
        .then(
      (value) {
        print("note Deleted");
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return Home_Page(
              currentUser: widget.userModel,
              firebaseUser: widget.firebaseUser,
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Note reader"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // confirmDelete();
          UIHelper.showAlerDialog(
            context,
            "Delete",
            "Are you sure?",
            () {
              deleteNote();
            },
          );
        },
        label: const Text("delete"),
        icon: const Icon(Icons.delete),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Title:",
              style: TextStyle(fontSize: 15.0),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
              child: Text(
                widget.currentNote.title.toString(),
                style: const TextStyle(fontSize: 17.0),
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Note:",
              style: TextStyle(fontSize: 15.0),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
              child: Text(
                widget.currentNote.note.toString(),
                style: const TextStyle(fontSize: 17.0),
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: size.width,
              width: size.width,
              // color: Colors.lightBlue,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    widget.currentNote.image.toString(),
                  ),
                ),
              ),
            ),
            Text(
              "last modified on:  ${widget.currentNote.createdon}",
            ),
          ],
        ),
      ),
    );
  }
}
