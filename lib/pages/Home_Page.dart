import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/models/NoteModel.dart';
import 'package:todo/models/UIHelper.dart';
import 'package:todo/models/User.dart';
import 'package:todo/pages/Create.dart';
import 'package:todo/pages/NoteReadder.dart';

class Home_Page extends StatefulWidget {
  final UserModel currentUser;
  final User firebaseUser;

  const Home_Page(
      {super.key, required this.currentUser, required this.firebaseUser});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  void logOut() async {
    await FirebaseAuth.instance.signOut().then((value) {});

    // UIHelper.showAlerDialog(context, "Log out", "Are you sure?");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      drawer: Drawer(
        width: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              color: Colors.lightGreenAccent,
              child: const Center(
                child: Text(
                  "Notes",
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
            const SizedBox(height: 400),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "User: ${widget.currentUser.email}",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
                onPressed: () {
                  logOut();
                },
                child: Row(
                  children: const [
                    Text("Log Out"),
                    SizedBox(width: 20),
                    Icon(Icons.exit_to_app)
                  ],
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Create_note(
              currentUser: widget.currentUser,
              firebaseUser: widget.firebaseUser,
            );
          }));
        },
        label: const Text("Add"),
        icon: const Icon(Icons.add),
      ),
//
//
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(widget.currentUser.uid)
              .collection("notes")
              .orderBy("createdon")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                //
                QuerySnapshot noteSnapshot = snapshot.data as QuerySnapshot;

                return GridView.builder(
                  itemCount: noteSnapshot.docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    // childAspectRatio: size.width / size.height / 0.7,
                    childAspectRatio: 1 / 1.55,
                  ),
                  itemBuilder: (context, index) {
                    NoteModel currentNote = NoteModel.fromMap(
                        noteSnapshot.docs[index].data()
                            as Map<String, dynamic>);

                    return Column(
                      children: [
                        //
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return NoteReader(
                                    currentNote,
                                    userModel: widget.currentUser,
                                    firebaseUser: widget.firebaseUser,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 7, top: 7, right: 7),
                            // height: size.height * 0.35,
                            width: size.width * 0.5,
                            decoration: BoxDecoration(
                              // color: Colors.yellow,
                              border: Border.all(
                                color: Colors.black.withOpacity(0.5),
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            //
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    currentNote.title.toString(),
                                    style: const TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: size.width * 0.47,
                                    width: size.width * 0.47,
                                    // color: Colors.lightBlue,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          currentNote.image.toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    currentNote.note.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //
                          ),
                        ),
                      ],
                    );
                  },
                );
                //
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("An error occured"),
                );
              } else {
                return const Center(
                  child: Text("An error occured"),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
